#!/usr/bin/env node

const childProcess = require("child_process");
const fs = require("fs");
const os = require("os");
const path = require("path");

const skillName = "codex-pet-director";

function log(message) {
  console.log(`[codex-pet-director] ${message}`);
}

function printNextStep() {
  log("Next step: restart Codex if needed, then paste this into Codex:");
  console.log("/create-pet");
}

function parseArgs(argv) {
  const options = {
    dryRun: false,
    installRoot: process.env.CODEX_PET_DIRECTOR_INSTALL_ROOT || "",
    agentsInstallRoot: process.env.CODEX_PET_DIRECTOR_AGENTS_INSTALL_ROOT || "",
    skipAgentsMirror: false,
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
    } else if (arg === "--agents-install-root") {
      i += 1;
      if (!argv[i]) {
        throw new Error("--agents-install-root requires a value");
      }
      options.agentsInstallRoot = argv[i];
    } else if (arg === "--skip-agents-mirror") {
      options.skipAgentsMirror = true;
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

function defaultAgentsInstallRoot() {
  if (process.env.AGENTS_HOME) {
    return path.join(process.env.AGENTS_HOME, "skills");
  }
  return path.join(os.homedir(), ".agents", "skills");
}

function assertInside(target, parent) {
  const fullTarget = path.resolve(target);
  const fullParent = path.resolve(parent);
  const relative = path.relative(fullParent, fullTarget);
  if (relative === "" || relative.startsWith("..") || path.isAbsolute(relative)) {
    throw new Error(`Refusing to write outside expected parent: ${fullTarget}`);
  }
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

function installSkillCopy(source, installRoot, label, dryRun) {
  const destination = path.join(installRoot, skillName);
  log(`${label} target: ${destination}`);

  if (dryRun) {
    return destination;
  }

  assertInside(destination, installRoot);
  fs.mkdirSync(installRoot, { recursive: true });
  fs.rmSync(destination, { recursive: true, force: true });
  copyDirectory(source, destination);
  return destination;
}

function main() {
  const options = parseArgs(process.argv.slice(2));
  const repositoryRoot = path.resolve(__dirname, "..");
  const source = path.join(repositoryRoot, skillName);
  const installRoot = path.resolve(options.installRoot || defaultInstallRoot());
  const agentsInstallRoot = path.resolve(options.agentsInstallRoot || defaultAgentsInstallRoot());
  const destination = path.join(installRoot, skillName);
  const shouldMirrorToAgents = !options.skipAgentsMirror && installRoot !== agentsInstallRoot;

  if (!fs.existsSync(path.join(source, "SKILL.md"))) {
    throw new Error(`Missing skill source: ${source}`);
  }

  log(`Source: ${source}`);
  log(`Codex skill root: ${installRoot}`);
  if (shouldMirrorToAgents) {
    log(`Agents skill mirror root: ${agentsInstallRoot}`);
  }

  if (options.dryRun) {
    installSkillCopy(source, installRoot, "Codex skill", true);
    if (shouldMirrorToAgents) {
      installSkillCopy(source, agentsInstallRoot, "Agents skill mirror", true);
    }
    log("Dry run only. No files were copied.");
    return;
  }

  installSkillCopy(source, installRoot, "Codex skill", false);
  log(`Installed ${skillName} to Codex skills`);
  if (shouldMirrorToAgents) {
    installSkillCopy(source, agentsInstallRoot, "Agents skill mirror", false);
    log(`Mirrored ${skillName} to Agents skills for skill search discovery`);
  }
  runEnvironmentCheck(destination);
  log("Done. Restart Codex if the skill list has not refreshed yet.");
  printNextStep();
}

try {
  main();
} catch (error) {
  console.error(`[codex-pet-director] ${error.message}`);
  process.exit(1);
}
