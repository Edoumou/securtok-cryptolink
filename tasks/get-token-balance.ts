import { task } from "hardhat/config";

// bugfix for metis + ethers6
const GAS_LIMIT = 0x500000;

task("get-token-balance", "")
	.addOptionalParam("wallet", "Custom wallet")
	.addOptionalParam("signer", "Custom signer (private key)")
	.addOptionalParam("provider", "Custom provider RPC url")
	.setAction(async (args, hre:any) => {
		const ethers = hre.ethers;
		const network = hre.network.name;
		const [deployer] = await ethers.getSigners();
        
		let signer = deployer;
		let wallet = deployer.address;
		if (args.signer) signer = new ethers.Wallet(args.signer, new ethers.providers.JsonRpcProvider(args.provider));
		if (args.wallet) wallet = args.wallet; 

		const bondERC7092 = await ethers.getContract("BondERC7092");
		const balance = await bondERC7092.connect(signer).balanceOf(wallet);
		console.log(wallet, 'has a balance of', Number(balance));
	});