import ethers from "ethers";
import fs  from "fs"


const file = fs.readFileSync("artifacts/contracts/starling.sol/starling.json", "utf8")
const json = JSON.parse(file)
const abi = json.abi

const providerRPC = {
  local: {
    name: "local",
    rpc: "http://127.0.0.1:8545",
    chainId: 31337,
  },
};
const provider = new ethers.providers.StaticJsonRpcProvider(
  providerRPC.local.rpc,
  {
    chainId: providerRPC.local.chainId,
    name: providerRPC.local.name,
  }
);
const privKey = "0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80"
const wallet = new ethers.Wallet(privKey,provider);
let add ="0xCf7Ed3AccA5a467e9e704C703E8D87F634fB0Fc9"
const contract = new ethers.Contract(add, abi, wallet);
let result = await contract.mint(100);

const receipt = await provider.waitForTransaction(result.hash, 1, 150000);//.then(() => {});
let tokenID=parseInt("0x" + receipt.logs[1].data.slice(-64),16);
let result1 = await contract.initializeLIT(tokenID, "Lit key here", JSON.stringify({"access":"condition"}));
let result2 = await contract.initializeToken(tokenID, "Description", "ipfs://QM_uri", "http://ipfs.xxx/site","org","collection");
console.log(result1)
console.log(result2)