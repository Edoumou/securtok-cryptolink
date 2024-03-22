import { DeployFunction } from "hardhat-deploy/types";

interface Bond {
	isin: string;
	name: string,
	symbol: string,
	currency: string,
	denomination: string,
	issueVolume: string,
	couponRate: string,
	issueDate: Number,
	maturityDate: Number
}

interface Issuer {
	account: string,
        logoURI: string,
        name: string,
        country: string,
        category: string,
        creditRating: string,
        carbonCredit: string
}

const func: DeployFunction = async function (hre: any) {
	const { deployer } = await hre.getNamedAccounts();
	const { deploy } = hre.deployments;

	let _issueDate = Date.now();
	let _maturitydate = _issueDate + 1200;

	let bond: Bond = {
		isin: "US9TH2BLOQ3T",
        name: "Amazon 2030",
        symbol: "AMZ30",
        currency: "0x0000000000000000000000000000000000000000",
        denomination: "1000",
        issueVolume: "1000000",
        couponRate: "500",
        issueDate: _issueDate,
        maturityDate: _maturitydate
	};

	let issuer: Issuer = {
		account: deployer,
        logoURI: "https://www.amazon/doc/logo.png",
        name: "Amazon",
        country: "US",
        category: "CORP",
        creditRating: "AA-",
        carbonCredit: "1200"
	};

	await deploy("BondERC7092", {
		from: deployer,
		args: [bond, issuer],
		log: true,
	});

	return hre.network.live;
};

export default func;
func.id = "deploy_Bond_ERC7092";
func.tags = ["BondERC7092"];
func.dependencies = [];
