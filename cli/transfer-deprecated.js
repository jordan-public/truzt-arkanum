#!/usr/bin/env node
import {
    Account,
    initThreadPool,
    ProgramManager,
    AleoKeyProvider,
    AleoKeyProviderParams
} from "@provablehq/sdk";
import { file_to_string } from './rw.js';

async function main() {
    // Expecting four parameters as command line arguments:
    // wrapper_token_id, amount, destination, nonce
    if (process.argv.length < 6) {
        console.log("Usage: node transfer.js <wrapper_token_id> <amount> <destination> <nonce>");
        process.exit(1);
    }

    await initThreadPool();

    const [wrapper_token_id, amount, destination, nonce] = process.argv.slice(2);

    // Load the trust program source code.
    const programName = "trust.aleo";
    const trust_program = file_to_string('../trust/src/main.leo');

    // Load the dependency token_registry program.
    const tokenRegistryProgram = file_to_string('../token_registry_workaround/src/main.leo');

    // Specify the imports as a list of strings.
    const imports = [ tokenRegistryProgram ];

    // Initialize the ProgramManager with a temporary account and key provider.
    const programManager = new ProgramManager();
    const account = new Account();
    programManager.setAccount(account);

    const keyProvider = new AleoKeyProvider();
    keyProvider.useCache(true);
    programManager.setKeyProvider(keyProvider);

    // Prepare inputs. They are passed as strings to the SDK.
    const functionName = "transfer";
    const inputs = [wrapper_token_id, amount, destination, nonce];

    // Pre-synthesize the proving/verifying keys and cache them.
    const keyPair = await programManager.synthesizeKeys(trust_program, functionName, inputs);
    programManager.keyProvider.cacheKeys(`${programName}:${functionName}`, keyPair);
    const keyProviderParams = new AleoKeyProviderParams({ cacheKey: `${programName}:${functionName}` });

    // Run the transfer execution with proof generation, passing the dependency via imports.
    let executionResponse = await programManager.run(
        trust_program,
        functionName,
        inputs,
        true,
        imports,
        keyProviderParams
    );
    console.log("transfer executed - result:", executionResponse.getOutputs());

    // Verify the execution using the pre-generated verifying key.
    if (programManager.verifyExecution(executionResponse)) {
        console.log("transfer execution verified!");
    } else {
        throw("Execution failed verification!");
    }
}

main().catch(err => {
    console.error("Error executing transfer:", err);
});