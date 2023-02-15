import ethers from "ethers";
import fs  from "fs"


const file = fs.readFileSync("artifacts/contracts/starling.sol/starling.json", "utf8")
const json = JSON.parse(file)
const abi = json.abi

const providerRPC = {
  local: {
    name: "local",
    rpc: "http://127.0.0.1:8545",
    chainId: 8545,
  },
};
const provider = new ethers.providers.StaticJsonRpcProvider(
  providerRPC.local.rpc,
  {
    chainId: providerRPC.local.chainId,
    name: providerRPC.local.name,
  }
);
let address="0xa85233C63b9Ee964Add6F2cffe00Fd84eb32338f"
const privKey = "0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80"
const wallet = new ethers.Wallet(privKey,provider);
const contract = new ethers.Contract(address, abi, wallet);
console.log(await contract.getTokenURI(1));