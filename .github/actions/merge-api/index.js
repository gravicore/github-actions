const core = require("@actions/core");
const { SSMClient, GetParameterCommand } = require("@aws-sdk/client-ssm");
const {
  AppSyncClient,
  AssociateMergedGraphqlApiCommand,
  ListSourceApiAssociationsCommand,
  StartSchemaMergeCommand
} = require("@aws-sdk/client-appsync");

async function retry(executable) {
  const maxAttempts = 10;
  for (let i = 0; i < maxAttempts; i++) {
    try {
      return await executable();
    } catch (error) {
      if (i === (maxAttempts - 1)) {
        console.log("Max retries reached, throwing error");
        throw error;
      }
      await (new Promise(r => setTimeout(r, 1000)));
    }
  }
}

function getAWSClient(Client) {
  const region = core.getInput("region");
  const accessKeyId = core.getInput("access_key_id");
  const secretAccessKey = core.getInput("secret_access_key");
  const sessionToken = core.getInput("session_token");
  const profile = core.getInput("profile");

  if (accessKeyId && secretAccessKey) {
    return new Client({
      region,
      credentials: {
        accessKeyId,
        secretAccessKey,
        sessionToken: sessionToken || null,
      },
    });
  }

  if (profile) {
    return new Client({ region, profile });
  }

  throw new Error("Either access_key_id and secret_access_key or profile must be provided");
}

async function getParameters(parameters) {
  const result = {};
  const resolveValues = core.getBooleanInput("resolve_values");
  if (!resolveValues) {
    for (const parameter of parameters) {
      result[parameter] = parameter;
    }
  } else {
    const decrypt = core.getBooleanInput("decrypt");
    const client = getAWSClient(SSMClient);
    for (const parameter of parameters) {
      const response = await client.send(new GetParameterCommand({
        Name: parameter,
        WithDecryption: decrypt,
      }));
      result[parameter] = response.Parameter.Value;
      console.log(`Parameter ${parameter} = ${result[parameter]}`);
    }
  }
  return result;
}

async function mergeGraphqlApi(sourceId, targetId) {
  await associateGraphqlApi(sourceId, targetId);
  const client = getAWSClient(AppSyncClient);
  const response = await client.send(new ListSourceApiAssociationsCommand({
    apiId: sourceId
  }));
  const associationId = response.sourceApiAssociationSummaries[0].associationId;
  await retry(async function() {
    await client.send(new StartSchemaMergeCommand({
      associationId: associationId,
      mergedApiIdentifier: targetId,
    }));
  });
  console.log("Schema merge completed with success");
  return associationId;
}

async function associateGraphqlApi(sourceId, targetId) {
  const client = getAWSClient(AppSyncClient);
  try {
    await client.send(new AssociateMergedGraphqlApiCommand({
      sourceApiIdentifier: sourceId,
      mergedApiIdentifier: targetId,
    }));
    console.log("Association completed with success");
  } catch (error) {
    if (error.$metadata.httpStatusCode === 400 && error.message === "SourceApiAssociation already exists.") {
      console.log("Existing association found, skipping association");
      return;
    }
    throw error;
  }
}

const main = async () => {
  try {
    const source = core.getInput("source", { required: true });
    const target = core.getInput("target", { required: true });
    const parameters = await getParameters([source, target]);
    const associationId = await mergeGraphqlApi(
      parameters[source],
      parameters[target],
    );
    core.setOutput("association_id", associationId);
  } catch (error) {
    core.setFailed(error.message);
    core.debug(error.stack);
  }
};

main();
