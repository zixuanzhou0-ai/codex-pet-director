#!/usr/bin/env node

const childProcess = require("child_process");
const crypto = require("crypto");
const fs = require("fs");
const os = require("os");
const path = require("path");

const skillName = "codex-pet-director";
const aliasSkillName = "create-pet";
const repositorySlug = "zixuanzhou0-ai/codex-pet-director";
const marketplaceName = "local-codex-pet-director";

function log(message) {
  console.log(`[codex-pet-director] ${message}`);
}

function printNextStep() {
  log("Next step: restart Codex if needed, then search create-pet in the slash menu or paste this into Codex:");
  console.log("/create-pet");
}

function parseArgs(argv) {
  const options = {
    dryRun: false,
    installRoot: process.env.CODEX_PET_DIRECTOR_INSTALL_ROOT || "",
    agentsInstallRoot: process.env.CODEX_PET_DIRECTOR_AGENTS_INSTALL_ROOT || "",
    codexHome: process.env.CODEX_HOME || "",
    marketplaceRoot: process.env.CODEX_PET_DIRECTOR_MARKETPLACE_ROOT || "",
    pluginRoot: process.env.CODEX_PET_DIRECTOR_PLUGIN_ROOT || "",
    skipAgentsMirror: false,
    skipPlugin: false,
    skipConfig: false,
    skipEnvironmentCheck: false,
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
    } else if (arg === "--codex-home") {
      i += 1;
      if (!argv[i]) {
        throw new Error("--codex-home requires a value");
      }
      options.codexHome = argv[i];
    } else if (arg === "--marketplace-root") {
      i += 1;
      if (!argv[i]) {
        throw new Error("--marketplace-root requires a value");
      }
      options.marketplaceRoot = argv[i];
    } else if (arg === "--plugin-root") {
      i += 1;
      if (!argv[i]) {
        throw new Error("--plugin-root requires a value");
      }
      options.pluginRoot = argv[i];
    } else if (arg === "--skip-agents-mirror") {
      options.skipAgentsMirror = true;
    } else if (arg === "--skip-plugin") {
      options.skipPlugin = true;
    } else if (arg === "--skip-config") {
      options.skipConfig = true;
    } else if (arg === "--skip-environment-check") {
      options.skipEnvironmentCheck = true;
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

function defaultCodexHome() {
  if (process.env.CODEX_HOME) {
    return process.env.CODEX_HOME;
  }
  return path.join(os.homedir(), ".codex");
}

function inferCodexHome(installRoot, explicitCodexHome) {
  if (explicitCodexHome) {
    return path.resolve(explicitCodexHome);
  }
  const resolvedInstallRoot = path.resolve(installRoot);
  if (path.basename(resolvedInstallRoot).toLowerCase() === "skills") {
    return path.dirname(resolvedInstallRoot);
  }
  return path.resolve(defaultCodexHome());
}

function defaultMarketplaceRoot() {
  return os.homedir();
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

function copyCleanDirectory(source, destination, allowedParent, dryRun) {
  log(`Copy target: ${destination}`);
  if (dryRun) {
    return;
  }

  assertInside(destination, allowedParent);
  fs.rmSync(destination, { recursive: true, force: true });
  fs.mkdirSync(path.dirname(destination), { recursive: true });
  copyDirectory(source, destination);
}

function resolveSkillSource(repositoryRoot, name = skillName) {
  const canonical = path.join(repositoryRoot, "skills", name);
  if (fs.existsSync(path.join(canonical, "SKILL.md"))) {
    return canonical;
  }

  const legacy = path.join(repositoryRoot, name);
  if (fs.existsSync(path.join(legacy, "SKILL.md"))) {
    return legacy;
  }

  throw new Error(`Missing skill source under ${repositoryRoot}`);
}

function sourceSkillPath(source, name = skillName) {
  const normalized = path.resolve(source).split(path.sep).join("/");
  if (normalized.endsWith(`/skills/${name}`)) {
    return `skills/${name}/SKILL.md`;
  }
  return `${name}/SKILL.md`;
}

function listFilesRecursive(root) {
  const files = [];
  for (const entry of fs.readdirSync(root, { withFileTypes: true })) {
    const entryPath = path.join(root, entry.name);
    if (entry.isDirectory()) {
      files.push(...listFilesRecursive(entryPath));
    } else if (entry.isFile()) {
      files.push(entryPath);
    }
  }
  return files;
}

function skillFolderHash(root) {
  const hash = crypto.createHash("sha1");
  const files = listFilesRecursive(root).sort((left, right) => left.localeCompare(right));
  for (const file of files) {
    const relative = path.relative(root, file).split(path.sep).join("/");
    hash.update(`${relative}\n`);
    hash.update(fs.readFileSync(file));
    hash.update("\n");
  }
  return hash.digest("hex");
}

function readJson(filePath) {
  if (!fs.existsSync(filePath)) {
    return null;
  }
  const raw = fs.readFileSync(filePath, "utf8");
  if (!raw.trim()) {
    return null;
  }
  return JSON.parse(raw);
}

function writeJson(filePath, value) {
  fs.mkdirSync(path.dirname(filePath), { recursive: true });
  fs.writeFileSync(filePath, `${JSON.stringify(value, null, 2)}\n`, "utf8");
}

function writeText(filePath, value) {
  fs.mkdirSync(path.dirname(filePath), { recursive: true });
  fs.writeFileSync(filePath, value, "utf8");
}

function tomlString(value) {
  return JSON.stringify(value);
}

function timestampForFile() {
  return new Date().toISOString().replace(/[-:T.Z]/g, "").slice(0, 14);
}

function timestampForToml() {
  return new Date().toISOString().replace(/\.\d{3}Z$/, "Z");
}

function updateAgentsSkillLock(agentsInstallRoot, installedSkill, skillPath, name = skillName) {
  if (!fs.existsSync(path.join(installedSkill, "SKILL.md"))) {
    log("Agents skill lock skipped because the Agents mirror was not installed.");
    return;
  }

  const agentsHome = path.dirname(path.resolve(agentsInstallRoot));
  const lockPath = path.join(agentsHome, ".skill-lock.json");
  const lock = readJson(lockPath) || { version: 3, skills: {} };
  if (!lock.version) {
    lock.version = 3;
  }
  if (!lock.skills || typeof lock.skills !== "object") {
    lock.skills = {};
  }

  const now = new Date().toISOString();
  const existing = lock.skills[name] || {};
  lock.skills[name] = {
    source: repositorySlug,
    sourceType: "github",
    sourceUrl: `https://github.com/${repositorySlug}.git`,
    skillPath,
    skillFolderHash: skillFolderHash(installedSkill),
    installedAt: existing.installedAt || now,
    updatedAt: now,
  };

  writeJson(lockPath, lock);
  log(`Updated Agents skill lock: ${lockPath}`);
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

function installSkillCopy(source, installRoot, label, dryRun, name = skillName) {
  const destination = path.join(installRoot, name);
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

function requireRepositoryPath(repositoryRoot, relativePath) {
  const target = path.join(repositoryRoot, ...relativePath.split("/"));
  if (!fs.existsSync(target)) {
    throw new Error(`Missing required repository path: ${relativePath}`);
  }
  return target;
}

function updateMarketplaceJson(marketplacePath) {
  const marketplace = readJson(marketplacePath) || {
    name: marketplaceName,
    interface: {
      displayName: "Local Codex Pet Director",
    },
    plugins: [],
  };

  if (!marketplace.name) {
    marketplace.name = marketplaceName;
  }
  if (!marketplace.interface || typeof marketplace.interface !== "object") {
    marketplace.interface = {};
  }
  if (!marketplace.interface.displayName) {
    marketplace.interface.displayName = "Local Codex Pet Director";
  }
  if (!Array.isArray(marketplace.plugins)) {
    marketplace.plugins = [];
  }

  marketplace.plugins = marketplace.plugins.filter((plugin) => plugin && plugin.name !== skillName);
  marketplace.plugins.push({
    name: skillName,
    source: {
      source: "local",
      path: `./plugins/${skillName}`,
    },
    policy: {
      installation: "AVAILABLE",
      authentication: "ON_INSTALL",
    },
    category: "Productivity",
  });

  writeJson(marketplacePath, marketplace);
}

function updateCodexConfig(configPath, sourceRoot) {
  fs.mkdirSync(path.dirname(configPath), { recursive: true });
  if (!fs.existsSync(configPath)) {
    writeText(configPath, "");
  }

  const backupPath = `${configPath}.bak-${timestampForFile()}`;
  fs.copyFileSync(configPath, backupPath);

  const marketplaceHeader = `[marketplaces.${marketplaceName}]`;
  const pluginHeader = `[plugins."${skillName}@${marketplaceName}"]`;
  const lines = fs.readFileSync(configPath, "utf8").split(/\r?\n/);
  const kept = [];
  let skip = false;

  for (const line of lines) {
    if (/^\s*\[.+\]\s*$/.test(line)) {
      const header = line.trim();
      if (header === marketplaceHeader || header === pluginHeader) {
        skip = true;
        continue;
      }
      skip = false;
    }

    if (!skip) {
      kept.push(line);
    }
  }

  const marketplaceBlock = [
    marketplaceHeader,
    `last_updated = ${tomlString(timestampForToml())}`,
    'source_type = "local"',
    `source = ${tomlString(path.resolve(sourceRoot))}`,
  ].join("\n");

  const pluginBlock = [
    pluginHeader,
    "enabled = true",
  ].join("\n");

  const content = `${kept.join("\n").trimEnd()}\n\n${marketplaceBlock}\n\n${pluginBlock}\n`;
  writeText(configPath, content);
  log(`Backed up Codex config: ${backupPath}`);
}

function installPluginMetadata(repositoryRoot, source, aliasSource, options, paths) {
  if (options.skipPlugin) {
    log("Plugin metadata install skipped.");
    return;
  }

  const manifestSource = requireRepositoryPath(repositoryRoot, ".codex-plugin/plugin.json");
  const commandsSource = requireRepositoryPath(repositoryRoot, "commands");
  const assetsSource = path.join(repositoryRoot, "assets");
  const manifest = readJson(manifestSource);
  if (!manifest || !manifest.version) {
    throw new Error(`Missing plugin version in ${manifestSource}`);
  }

  const pluginParent = path.join(paths.marketplaceRoot, "plugins");
  const pluginRoot = path.resolve(options.pluginRoot || path.join(pluginParent, skillName));
  const marketplacePath = path.join(paths.marketplaceRoot, ".agents", "plugins", "marketplace.json");
  const pluginCacheParent = path.join(paths.codexHome, "plugins", "cache", marketplaceName);
  const pluginCachePluginRoot = path.join(pluginCacheParent, skillName);
  const pluginCacheRoot = path.join(pluginCachePluginRoot, manifest.version);
  const configPath = path.join(paths.codexHome, "config.toml");

  log(`Plugin target: ${pluginRoot}`);
  log(`Codex plugin cache: ${pluginCacheRoot}`);
  log(`Marketplace: ${marketplacePath}`);
  log(`Codex config: ${configPath}`);

  if (options.dryRun) {
    log("Would install local plugin metadata.");
    return;
  }

  assertInside(pluginRoot, pluginParent);
  assertInside(marketplacePath, paths.marketplaceRoot);
  assertInside(configPath, paths.codexHome);
  assertInside(pluginCachePluginRoot, pluginCacheParent);
  assertInside(pluginCacheRoot, pluginCacheParent);

  fs.rmSync(pluginRoot, { recursive: true, force: true });
  fs.mkdirSync(pluginRoot, { recursive: true });
  copyCleanDirectory(source, path.join(pluginRoot, "skills", skillName), pluginRoot, false);
  copyCleanDirectory(aliasSource, path.join(pluginRoot, "skills", aliasSkillName), pluginRoot, false);
  copyCleanDirectory(commandsSource, path.join(pluginRoot, "commands"), pluginRoot, false);
  if (fs.existsSync(assetsSource)) {
    copyCleanDirectory(assetsSource, path.join(pluginRoot, "assets"), pluginRoot, false);
  }

  const pluginManifest = {
    ...manifest,
    skills: "./skills/",
    commands: "./commands/",
  };
  writeJson(path.join(pluginRoot, ".codex-plugin", "plugin.json"), pluginManifest);

  fs.rmSync(pluginCachePluginRoot, { recursive: true, force: true });
  fs.mkdirSync(path.dirname(pluginCacheRoot), { recursive: true });
  copyDirectory(pluginRoot, pluginCacheRoot);

  updateMarketplaceJson(marketplacePath);
  if (!options.skipConfig) {
    updateCodexConfig(configPath, paths.marketplaceRoot);
  }

  log("Installed local plugin package metadata.");
}

function main() {
  const options = parseArgs(process.argv.slice(2));
  const repositoryRoot = path.resolve(__dirname, "..");
  const source = resolveSkillSource(repositoryRoot, skillName);
  const aliasSource = resolveSkillSource(repositoryRoot, aliasSkillName);
  const installRoot = path.resolve(options.installRoot || defaultInstallRoot());
  const agentsInstallRoot = path.resolve(options.agentsInstallRoot || defaultAgentsInstallRoot());
  const codexHome = inferCodexHome(installRoot, options.codexHome);
  const marketplaceRoot = path.resolve(options.marketplaceRoot || defaultMarketplaceRoot());
  const destination = path.join(installRoot, skillName);
  const agentsDestination = path.join(agentsInstallRoot, skillName);
  const aliasAgentsDestination = path.join(agentsInstallRoot, aliasSkillName);
  const shouldMirrorToAgents = !options.skipAgentsMirror && installRoot !== agentsInstallRoot;

  log(`Source: ${source}`);
  log(`Codex skill root: ${installRoot}`);
  if (shouldMirrorToAgents) {
    log(`Agents skill mirror root: ${agentsInstallRoot}`);
  }
  log(`Codex home: ${codexHome}`);
  log(`Marketplace root: ${marketplaceRoot}`);

  if (options.dryRun) {
    installSkillCopy(source, installRoot, "Codex skill", true);
    installSkillCopy(aliasSource, installRoot, "Codex slash alias skill", true, aliasSkillName);
    if (shouldMirrorToAgents) {
      installSkillCopy(source, agentsInstallRoot, "Agents skill mirror", true);
      installSkillCopy(aliasSource, agentsInstallRoot, "Agents slash alias mirror", true, aliasSkillName);
    }
    if (!options.skipAgentsMirror) {
      log(`Would update Agents skill lock under ${agentsInstallRoot}`);
    }
    installPluginMetadata(repositoryRoot, source, aliasSource, options, { codexHome, marketplaceRoot });
    log("Dry run only. No files were copied.");
    return;
  }

  installSkillCopy(source, installRoot, "Codex skill", false);
  log(`Installed ${skillName} to Codex skills`);
  installSkillCopy(aliasSource, installRoot, "Codex slash alias skill", false, aliasSkillName);
  log(`Installed ${aliasSkillName} slash entry to Codex skills`);
  if (shouldMirrorToAgents) {
    installSkillCopy(source, agentsInstallRoot, "Agents skill mirror", false);
    installSkillCopy(aliasSource, agentsInstallRoot, "Agents slash alias mirror", false, aliasSkillName);
    log(`Mirrored ${skillName} to Agents skills for skill search discovery`);
  }
  if (!options.skipAgentsMirror) {
    updateAgentsSkillLock(agentsInstallRoot, agentsDestination, sourceSkillPath(source, skillName), skillName);
    updateAgentsSkillLock(agentsInstallRoot, aliasAgentsDestination, sourceSkillPath(aliasSource, aliasSkillName), aliasSkillName);
  }
  installPluginMetadata(repositoryRoot, source, aliasSource, options, { codexHome, marketplaceRoot });
  if (!options.skipEnvironmentCheck) {
    runEnvironmentCheck(destination);
  }
  log("Done. Restart Codex if the skill list has not refreshed yet.");
  printNextStep();
}

try {
  main();
} catch (error) {
  console.error(`[codex-pet-director] ${error.message}`);
  process.exit(1);
}
