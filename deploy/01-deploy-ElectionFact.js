const { network, ethers } = require('hardhat')

const { developmentChains, networkConfig } = require('../helper-hardhat-config')

const { verify } = require('../utils/helper-function')

module.exports = async ({getNamedAccounts, deployments}) => {

    
    const chainId = network.config.chainId

    const { deploy, log } = deployments

    const { deployer } = await getNamedAccounts()

    const args = []

    log('---------------------------------------')

    const ElectionFact = await deploy('ElectionFact', {

        from: deployer,

        args: args,

        log: true,

        waitConfirmations: networkConfig[chainId].blockConfirmations || 1

    })

    const ElectionFactContract = await ethers.getContract('ElectionFact')

    const ContractAddress = await ElectionFactContract.getAddress()

    if(!developmentChains.includes(network.name) && process.env.ETHERSCAN_API_KEY){

       await verify(ContractAddress, args)

    }

}

module.exports.tags = ['all', 'ElectionFact']