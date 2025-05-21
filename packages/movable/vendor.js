#!/usr/bin/env node

const PACKAGE = "movable";
const LOCAL_PATH = "assets/js/hooks";

const fs = require("fs");
const path = require("path");

const sourceFile = path.join(__dirname, "src/index.js");
const vendorDir = path.resolve(process.cwd(), LOCAL_PATH);
const vendorFile = path.join(vendorDir, `${PACKAGE}.js`);

fs.mkdirSync(vendorDir, { recursive: true });
fs.copyFileSync(sourceFile, vendorFile);

console.log(`Added @phx-hook/${PACKAGE} to ./${LOCAL_PATH}/${PACKAGE}.js`);
