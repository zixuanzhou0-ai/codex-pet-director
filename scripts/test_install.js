#!/usr/bin/env node

const childProcess = require("child_process");
const fs = require("fs");
const os = require("os");
const path = require("path");

const repoRoot = path.resolve(__dirname, "..");
const tempRoot = fs.mkdtempSync(path.join(os.tmpdir(), "codex-pet-director-install-"));

function fail(message) {
  console.error(`[test-install] ${message}`);
  process.exitCode = 1;
}

function assert(condition, message) {
  if (!condition) {
    throw new Error(message);
  }
}

function assertExists(filePath) {
  assert(fs.existsSync(filePath), `Missing expected path: ${filePath}`);
}

function readJson(filePath) {
  return JSON.parse(fs.readFileSync(filePath, "utf8"));
}

function assertNoBom(filePath) {
  const bytes = fs.readFileSync(filePath);
  const hasBom = bytes.length >= 3 && bytes[0] === 0xef && bytes[1] === 0xbb && bytes[2] === 0xbf;
  assert(!hasBom, `File must be UTF-8 without BOM: ${filePath}`);
}

try {
  const codexHome = path.join(tempRoot, ".codex");
  const agentsHome = path.join(tempRoot, ".agents");
  const marketplaceRoot = path.join(tempRoot, "home");
  const installRoot = path.join(codexHome, "skills");
  const agentsInstallRoot = path.join(agentsHome, "skills");

  const result = childProcess.spawnSync(process.execPath, [
    path.join(repoRoot, "bin", "install.js"),
    "--codex-home", codexHome,
    "--install-root", installRoot,
    "--agents-install-root", agentsInstallRoot,
    "--marketplace-root", marketplaceRoot,
    "--skip-environment-check",
  ], {
    cwd: repoRoot,
    encoding: "utf8",
    env: {
      ...process.env,
      CODEX_HOME: codexHome,
      AGENTS_HOME: agentsHome,
      CODEX_PET_DIRECTOR_MARKETPLACE_ROOT: marketplaceRoot,
    },
  });

  if (result.status !== 0) {
    process.stdout.write(result.stdout || "");
    process.stderr.write(result.stderr || "");
    throw new Error(`Installer exited with status ${result.status}`);
  }

  if (process.platform === "win32") {
    const powershell = childProcess.spawnSync("powershell", [
      "-NoProfile",
      "-ExecutionPolicy", "Bypass",
      "-File", path.join(repoRoot, "install.ps1"),
      "-CodexHome", codexHome,
      "-MarketplaceRoot", marketplaceRoot,
      "-AgentsInstallRoot", agentsInstallRoot,
    ], {
      cwd: repoRoot,
      encoding: "utf8",
      env: {
        ...process.env,
        CODEX_HOME: codexHome,
        AGENTS_HOME: agentsHome,
      },
    });

    if (powershell.status !== 0) {
      process.stdout.write(powershell.stdout || "");
      process.stderr.write(powershell.stderr || "");
      throw new Error(`PowerShell installer exited with status ${powershell.status}`);
    }
  }

  const version = readJson(path.join(repoRoot, ".codex-plugin", "plugin.json")).version;
  const pluginRoot = path.join(marketplaceRoot, "plugins", "codex-pet-director");
  const cacheRoot = path.join(codexHome, "plugins", "cache", "local-codex-pet-director", "codex-pet-director", version);
  const marketplacePath = path.join(marketplaceRoot, ".agents", "plugins", "marketplace.json");
  const configPath = path.join(codexHome, "config.toml");
  const lockPath = path.join(agentsHome, ".skill-lock.json");

  for (const root of [pluginRoot, cacheRoot]) {
    assertExists(path.join(root, ".codex-plugin", "plugin.json"));
    assertExists(path.join(root, "skills", "codex-pet-director", "SKILL.md"));
    assertExists(path.join(root, "skills", "create-pet", "SKILL.md"));
    assertExists(path.join(root, "skills", "codex-pet-director", "scripts", "check_pet_asset_fit.py"));
    assertExists(path.join(root, "skills", "codex-pet-director", "scripts", "check_hatch_output.py"));
    assertExists(path.join(root, "skills", "codex-pet-director", "scripts", "build_hatch_handoff.py"));
    assertExists(path.join(root, "commands", "create-pet.md"));
    assertExists(path.join(root, "assets", "examples", "wukong-spark", "preview.png"));

    const manifest = readJson(path.join(root, ".codex-plugin", "plugin.json"));
    assert(manifest.skills === "./skills/", `Plugin manifest has wrong skills path under ${root}`);
    assert(manifest.commands === "./commands/", `Plugin manifest has wrong commands path under ${root}`);
  }

  assertExists(path.join(installRoot, "codex-pet-director", "SKILL.md"));
  assertExists(path.join(installRoot, "create-pet", "SKILL.md"));
  assertExists(path.join(installRoot, "codex-pet-director", "scripts", "check_pet_asset_fit.py"));
  assertExists(path.join(installRoot, "codex-pet-director", "scripts", "check_hatch_output.py"));
  assertExists(path.join(installRoot, "codex-pet-director", "scripts", "build_hatch_handoff.py"));
  assertExists(path.join(agentsInstallRoot, "codex-pet-director", "SKILL.md"));
  assertExists(path.join(agentsInstallRoot, "create-pet", "SKILL.md"));
  assertExists(path.join(agentsInstallRoot, "codex-pet-director", "scripts", "check_hatch_output.py"));
  assertExists(marketplacePath);
  assertExists(configPath);
  assertExists(lockPath);

  assertNoBom(marketplacePath);
  assertNoBom(configPath);

  const marketplace = readJson(marketplacePath);
  assert(Array.isArray(marketplace.plugins), "Marketplace plugins must be an array");
  assert(marketplace.plugins.some((plugin) => plugin.name === "codex-pet-director"), "Marketplace must contain codex-pet-director");

  const config = fs.readFileSync(configPath, "utf8");
  assert(config.includes("[marketplaces.local-codex-pet-director]"), "Config missing marketplace block");
  assert(config.includes('[plugins."codex-pet-director@local-codex-pet-director"]'), "Config missing plugin block");

  const lock = readJson(lockPath);
  assert(lock.skills["codex-pet-director"], "Skill lock missing codex-pet-director");
  assert(lock.skills["create-pet"], "Skill lock missing create-pet");

  console.log(`[test-install] Passed in ${tempRoot}`);
} catch (error) {
  fail(error.message);
} finally {
  if (!process.env.CODEX_PET_DIRECTOR_KEEP_TEST_TEMP) {
    fs.rmSync(tempRoot, { recursive: true, force: true });
  }
}
