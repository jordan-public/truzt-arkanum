#!/usr/bin/env node
import { Account } from "@provablehq/sdk";
import { fileURLToPath } from 'url';
import { dirname, resolve } from 'path';
import dotenv from 'dotenv';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);
dotenv.config({ path: resolve(__dirname, '.env') });

const account = new Account({ privateKey: process.env.PRIVATE_KEY });
const privateKey = account.privateKey();
const viewKey = account.viewKey();
const address = account.address();

console.log("View Key:", viewKey.to_string());
console.log("Address:", address.to_string());
