#!/usr/bin/env node

const childProcess = require("child_process");
const fs = require("fs");
const os = require("os");
const path = require("path");

const skillName = "codex-pet-director";

function log(message) {
  console.log(`[codex-pet-director] ${message}`);
}

function parseArgs(argv) {
  const options = {
    dryRun: false,
    installRoot: process.env.CODEX_PET_DIRECTOR_INSTALL_ROOT || "",
  };

  for (let i = 0; i < argv.length; i += 1) {
    const arg = argv[i];
    if (arg === "--dry-run") {
      options.dryRun = true;
    } else if (arg === "--install-root") {
      i += 1;
      if (!argv[i]) {
        throw new Error("--install-root requires a value");
      }
      options.installRoot = argv[i];
    } else {
      throw new Error(`Unknown option: ${arg}`);
    }
  }

  return options;
}

function defaultInstallRoot() {
  if (process.env.CODEX_HOME) {
    return path.join(process.env.CODEX_HOME, "skills");
  }
  return path.join(os.homedir(), ".codex", "skills");
}

function copyDirectory(source, destination) {
  fs.mkdirSync(destination, { recursive: true });
  for (const entry of fs.readdirSync(source, { withFileTypes: true })) {
    const sourcePath = path.join(source, entry.name);
    const destinationPath = path.join(destination, entry.name);
    if (entry.isDirectory()) {
      copyDirectory(sourcePath, destinationPath);
    } else if (entry.isFile()) {
      fs.copyFileSync(sourcePath, destinationPath);
    }
  }
}

function commandExists(command, args = ["--version"]) {
  const result = childProcess.spawnSync(command, args, {
    encoding: "utf8",
    stdio: "ignore",
    shell: process.platform === "win32",
  });
  return result.status === 0;
}

function runEnvironmentCheck(installedSkill) {
  const checkScript = path.join(installedSkill, "scripts", "check_pet_environment.py");
  if (!fs.existsSync(checkScript)) {
    log("Environment check script was not found.");
    return;
  }

  const candidates = process.platform === "win32"
    ? [
        { command: "py", args: ["-3", checkScript, "--fix"] },
        { command: "python", args: [checkScript, "--fix"] },
      ]
    : [
        { command: "python3", args: [checkScript, "--fix"] },
        { command: "python", args: [checkScript, "--fix"] },
      ];

  const candidate = candidates.find((item) => commandExists(item.command));
  if (!candidate) {
    log("Python was not found, so the environment check was skipped.");
    return;
  }

  log("Running environment check");
  const result = childProcess.spawnSync(candidate.command, candidate.args, {
    stdio: "inherit",
    shell: process.platform === "win32",
  });

  if (result.status !== 0) {
    log("Environment check reported issues. The skill was installed, but Codex pet support may still need attention.");
  }
}

function main() {
  const options = parseArgs(process.argv.slice(2));
  const repositoryRoot = path.resolve(__dirname, "..");
  const source = path.join(repositoryRoot, skillName);
  const installRoot = path.resolve(options.installRoot || defaultInstallRoot());
  const destination = path.join(installRoot, skillName);

  if (!fs.existsSync(path.join(source, "SKILL.md"))) {
    throw new Error(`Missing skill source: ${source}`);
  }

  log(`Source: ${source}`);
  log(`Install target: ${destination}`);

  if (options.dryRun) {
    log("Dry run only. No files were copied.");
    return;
  }

  fs.mkdirSync(installRoot, { recursive: true });
  fs.rmSync(destination, { recursive: true, force: true });
  copyDirectory(source, destination);
  log(`Installed ${skillName}`);
  runEnvironmentCheck(destination);
  log("Done. Restart Codex if the skill list has not refreshed yet.");
}

try {
  main();
} catch (error) {
  console.error(`[codex-pet-director] ${error.message}`);
  process.exit(1);
}
