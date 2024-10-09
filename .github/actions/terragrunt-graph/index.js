const core = require("@actions/core");
const fs = require("fs");
const path = require("path");
const parse = require("hcl-to-json");

const DIRECTORY = core.getInput("directory", { required: false });
const FILENAME = core.getInput("filename", { required: false });
const EXCLUSION = core.getInput("exclusion", { required: false });

function listHCL(directory) {
  let results = [];
  for (let hcl of fs.readdirSync(directory)) {
    hcl = path.resolve(directory, hcl);
    const stat = fs.statSync(hcl);
    if (stat && stat.isDirectory()) {
      results = results.concat(listHCL(hcl));
    } else if (hcl.endsWith(FILENAME)) {
      results.push(hcl);
    }
  }
  return results;
};

function getName(hcl) {
  return hcl.replace(`/${FILENAME}`, "")
    .split(`${DIRECTORY}/`)[1];
}

function getDependencies(map) {
  const exclusion = EXCLUSION.split(" ").map(e => e.replace(`${DIRECTORY}/`, ""));
  return map
    ? Object.keys(map).map(key => {
      const parts = map[key].config_path.split("/");
      return parts.filter(part => part !== "..").join("/");
    }).filter(name => !(exclusion.includes(name) || exclusion.includes(`${name}/`)))
    : [];
}

function getModules() {
  const modules = {};
  for (const hcl of listHCL(DIRECTORY)) {
    const module = getName(hcl);
    if (module && module !== "") {
      const json = parse(fs.readFileSync(hcl, "utf8"));
      modules[module] = getDependencies(json.dependency);
    }
  }
  return modules;
}

function getRawGraph() {
  const modules = getModules();
  const dependencyMap = new Map();
  for (const [key, values] of Object.entries(modules)) {
    if (!dependencyMap.has(key)) {
      dependencyMap.set(key, new Set());
    }
    values.forEach(value => {
      if (!dependencyMap.has(value)) {
        dependencyMap.set(value, new Set());
      }
      dependencyMap.get(key).add(value);
      dependencyMap.get(value).add(key);
    });
  }

  const results = [];
  const visited = new Set();

  for (const [key] of dependencyMap.entries()) {
    if (!visited.has(key)) {
      const group = new Set();
      const stack = [key];
      while (stack.length > 0) {
        const current = stack.pop();
        if (!visited.has(current)) {
          visited.add(current);
          group.add(current);
          dependencyMap.get(current).forEach(dep => {
            if (!visited.has(dep)) {
              stack.push(dep);
            }
          });
        }
      }
      results.push(Array.from(group));
    }
  }
  results.forEach(group => group.sort());
  return results;
}

function sorted(graph) {
  const keys = Object.keys(graph).sort();
  const sort = {};
  for (const key of keys) {
    sort[key] = graph[key];
  }
  return sort;
};

function getGraph() {
  const graph = {};
  let i = 1;
  for (const rg of getRawGraph()) {
    if (rg.length === 1) {
      graph[rg[0]] = rg;
    } else {
      graph[`__group-${i.toString().padStart(2, "0")}__`] = rg;
      i++;
    }
  }
  return sorted(graph);
}

async function main() {
  try {
    const graph = getGraph();
    console.log(`Graph: ${JSON.stringify(graph)}`);
    console.log(`Modules: ${Object.keys(graph)}`);
    core.setOutput("graph", JSON.stringify(graph));
    core.setOutput("modules", JSON.stringify(Object.keys(graph)));
  } catch (error) {
    core.setFailed(error.message);
    core.debug(error.stack);
  }
};

main();
