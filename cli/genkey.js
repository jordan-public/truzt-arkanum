#!/usr/bin/env node
import { Account } from "@provablehq/sdk";

const account = new Account();
const privateKey = account.privateKey();
const viewKey = account.viewKey();
const address = account.address();

console.log("Private Key:", privateKey.to_string());
console.log("View Key:", viewKey.to_string());
console.log("Address:", address.to_string());
