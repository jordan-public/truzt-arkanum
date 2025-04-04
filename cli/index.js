import {Account, initThreadPool, ProgramManager, AleoKeyProvider, AleoKeyProviderParams} from "@provablehq/sdk";
import { file_to_string } from './rw.js';

await initThreadPool();

const programName = "hello_hello.aleo";
const hello_hello_program = file_to_string('./programs/hello_hello.aleo');

async function localProgramExecution(program, programName, aleoFunction, inputs) {
    const programManager = new ProgramManager();

    // Create a temporary account for the execution of the program
    const account = new Account();
    programManager.setAccount(account);

    // Create a key provider in order to re-use the same key for each execution
    const keyProvider = new AleoKeyProvider();
    keyProvider.useCache(true);
    programManager.setKeyProvider(keyProvider);

    // Pre-synthesize the program keys and then cache them in memory using key provider
    const keyPair = await programManager.synthesizeKeys(program, aleoFunction, inputs);
    programManager.keyProvider.cacheKeys(`${programName}:${aleoFunction}`, keyPair);

    // Specify parameters for the key provider to use search for program keys. In particular specify the cache key
    // that was used to cache the keys in the previous step.
    const keyProviderParams = new AleoKeyProviderParams({cacheKey: `${programName}:${aleoFunction}`});

    // Execute once using the key provider params defined above. This will use the cached proving keys and make
    // execution significantly faster.
    let executionResponse = await programManager.run(
        program,
        aleoFunction,
        inputs,
        true,
        undefined,
        keyProviderParams,
    );
    console.log("hello_hello/hello executed - result:", executionResponse.getOutputs());

    // Verify the execution using the verifying key that was generated earlier.
    if (programManager.verifyExecution(executionResponse)) {
        console.log("hello_hello/hello execution verified!");
    } else {
        throw("Execution failed verification!");
    }
}

const start = Date.now();
console.log("Starting execute!");
await localProgramExecution(hello_hello_program, programName, "hello", ["5u32", "5u32"]);
console.log("Execute finished!", Date.now() - start);
