import { task } from "hardhat/config";

task("bridge-token", "")
    .addParam("dest", "Destination chain id")
	.addParam("amount", "Amount of tokens in ETH")
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

		await(await bondERC7092.connect(signer).approve(signer.address, args.amount.toString())).wait();

		let destinationChain = hre.ethers.toBeHex(11155111, 32);

		await bondERC7092.connect(signer).crossChainTransfer.estimateGas(
			wallet,
			args.amount.toString(),
			hre.ethers.keccak256(hre.ethers.toUtf8Bytes("")),
			destinationChain,
			bondERC7092.target
		);

		await(await bondERC7092.connect(signer).crossChainTransfer(
				wallet,
				args.amount.toString(),
				hre.ethers.keccak256(hre.ethers.toUtf8Bytes("")),
				destinationChain,
				bondERC7092.target
			)
		).wait();

		console.log('sent',args.amount,' of tokens to', wallet, 'on chain id', args.dest);
	});
