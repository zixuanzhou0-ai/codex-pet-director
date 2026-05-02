#!/usr/bin/env node

const crypto = require("crypto");
const fs = require("fs");
const path = require("path");

const repoRoot = path.resolve(__dirname, "..");

function assert(condition, message) {
  if (!condition) {
    throw new Error(message);
  }
}

function readText(relativePath) {
  return fs.readFileSync(path.join(repoRoot, relativePath), "utf8");
}

function readJson(relativePath) {
  return JSON.parse(readText(relativePath));
}

function listFiles(root) {
  const files = [];
  for (const entry of fs.readdirSync(root, { withFileTypes: true })) {
    const entryPath = path.join(root, entry.name);
    if (entry.isDirectory()) {
      files.push(...listFiles(entryPath));
    } else if (entry.isFile()) {
      files.push(entryPath);
    }
  }
  return files;
}

function fileHash(filePath) {
  return crypto.createHash("sha256").update(fs.readFileSync(filePath)).digest("hex");
}

function relativeMap(root) {
  const resolvedRoot = path.resolve(root);
  const map = new Map();
  for (const file of listFiles(resolvedRoot)) {
    const relative = path.relative(resolvedRoot, file).split(path.sep).join("/");
    map.set(relative, fileHash(file));
  }
  return map;
}

function assertMirrorsMatch(left, right) {
  const leftMap = relativeMap(path.join(repoRoot, left));
  const rightMap = relativeMap(path.join(repoRoot, right));
  const keys = new Set([...leftMap.keys(), ...rightMap.keys()]);
  for (const key of keys) {
    assert(leftMap.get(key) === rightMap.get(key), `Mirror mismatch: ${left}/${key} != ${right}/${key}`);
  }
}

function assertNoBom(relativePath) {
  const bytes = fs.readFileSync(path.join(repoRoot, relativePath));
  const hasBom = bytes.length >= 3 && bytes[0] === 0xef && bytes[1] === 0xbb && bytes[2] === 0xbf;
  assert(!hasBom, `File must be UTF-8 without BOM: ${relativePath}`);
}

function assertSkillFrontmatter(relativePath) {
  const text = readText(relativePath);
  assert(text.startsWith("---\n") || text.startsWith("---\r\n"), `Skill missing frontmatter: ${relativePath}`);
  const match = text.match(/^---\r?\n([\s\S]*?)\r?\n---/);
  assert(match, `Skill frontmatter is not closed: ${relativePath}`);
  assert(/^name:\s*\S+/m.test(match[1]), `Skill frontmatter missing name: ${relativePath}`);
  assert(/^description:\s*\S+/m.test(match[1]), `Skill frontmatter missing description: ${relativePath}`);
}

function isExternalLink(link) {
  return /^(https?:|mailto:|#|app:\/\/|plugin:\/\/)/i.test(link);
}

function normalizeLink(raw) {
  return raw.trim().replace(/^<|>$/g, "").split("#")[0];
}

function assertMarkdownLinks(relativePath) {
  const absolutePath = path.join(repoRoot, relativePath);
  const directory = path.dirname(absolutePath);
  const text = fs.readFileSync(absolutePath, "utf8");
  const patterns = [
    /!\[[^\]]*\]\(([^)]+)\)/g,
    /(?<!!)\[[^\]]+\]\(([^)]+)\)/g,
    /<img\s+[^>]*src=["']([^"']+)["'][^>]*>/gi,
  ];

  for (const pattern of patterns) {
    let match;
    while ((match = pattern.exec(text)) !== null) {
      const link = normalizeLink(match[1]);
      if (!link || isExternalLink(link)) {
        continue;
      }
      const target = path.resolve(directory, link);
      assert(fs.existsSync(target), `Broken local link in ${relativePath}: ${match[1]}`);
    }
  }
}

function main() {
  assertMirrorsMatch("skills/codex-pet-director", "codex-pet-director");

  for (const skill of [
    "skills/codex-pet-director/SKILL.md",
    "skills/create-pet/SKILL.md",
    "codex-pet-director/SKILL.md",
  ]) {
    assertSkillFrontmatter(skill);
  }

  for (const file of [
    ".codex-plugin/plugin.json",
    "package.json",
    "install.ps1",
    "install-plugin.ps1",
    "bin/install.js",
  ]) {
    assertNoBom(file);
  }

  const packageJson = readJson("package.json");
  const pluginJson = readJson(".codex-plugin/plugin.json");
  assert(packageJson.version === pluginJson.version, "package.json version must match plugin.json version");
  assert(packageJson.files.includes(".codex-plugin/plugin.json"), "package files must include plugin manifest");
  assert(packageJson.files.includes("commands/**/*"), "package files must include commands");
  assert(packageJson.files.includes("skills/**/*"), "package files must include skills");
  assert(packageJson.files.includes("assets/**/*"), "package files must include assets");

  for (const screenshot of pluginJson.interface.screenshots || []) {
    const target = path.join(repoRoot, screenshot.replace(/^\.\//, ""));
    assert(fs.existsSync(target), `Plugin screenshot is missing: ${screenshot}`);
  }

  const markdownFiles = listFiles(repoRoot)
    .filter((file) => file.endsWith(".md"))
    .filter((file) => !file.includes(`${path.sep}.git${path.sep}`))
    .filter((file) => !file.includes(`${path.sep}.codex_app_asar_extract${path.sep}`))
    .filter((file) => !file.includes(`${path.sep}node_modules${path.sep}`))
    .filter((file) => !file.includes(`${path.sep}runs${path.sep}`))
    .map((file) => path.relative(repoRoot, file).split(path.sep).join("/"));

  for (const markdownFile of markdownFiles) {
    assertMarkdownLinks(markdownFile);
  }

  console.log("[validate-repository] Passed");
}

try {
  main();
} catch (error) {
  console.error(`[validate-repository] ${error.message}`);
  process.exit(1);
}
