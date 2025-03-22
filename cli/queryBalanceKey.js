#!/usr/bin/env node

import { fileURLToPath } from 'url';
import { dirname, resolve } from 'path';
import dotenv from 'dotenv';
import { Account, AleoNetworkClient, AleoKeyProvider, NetworkRecordProvider, ProgramManager } from '@provablehq/sdk';
import { file_to_string } from './rw.js';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

dotenv.config({ path: resolve(__dirname, '.env') });

export async function queryBalanceKey(address, tokenId) {
    // Initialize Aleo account from private key
    const account = new Account({ privateKey: process.env.PRIVATE_KEY });
    
    // Initialize network client and program manager
    const networkClient = new AleoNetworkClient(process.env.ENDPOINT);
    const keyProvider = new AleoKeyProvider();
    keyProvider.useCache = true; // Enable key caching
    const recordProvider = new NetworkRecordProvider(account, networkClient);
    const programManager = new ProgramManager(process.env.ENDPOINT, keyProvider, recordProvider);
    programManager.setAccount(account);

    const program = file_to_string("../trust/build/main.aleo");
    const token_registry_program = file_to_string("../token_registry_workaround/build/main.aleo");

    try {
        // Validate programs before execution
        if (!program || !token_registry_program) {
            throw new Error("Failed to load program files");
        }

        const executionResponse = await programManager.run(
            program,
            "balance_key",
            [address, tokenId],
            false,
            { "token_registry.aleo": token_registry_program },
        );

        if (!executionResponse || !executionResponse.getOutputs()) {
            throw new Error("No output received from program execution");
        }

        return executionResponse.getOutputs()[0];
    } catch (error) {
        console.error("Detailed error:", error);
        throw new Error(`Error querying balance key: ${error.message}`);
    }
}
