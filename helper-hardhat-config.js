const networkConfig = {

    31337: {
        name: "localhost",
        blockConfirmations: 1
    },
    1337: {
        name: "localhost",
        blockConfirmations: 1
    },
    11155111: {
        name: "sepolia",
        blockConfirmations: 6
    },
    80001: {
        name: "mumbai",
        blockConfirmations: 6
    },
    1: {
        name: "mainnet",
        blockConfirmations: 6
    },
    137: {
        name: "polygon",
        blockConfirmations: 6
    },
}

const developmentChains = ['localhost', 'hardhat']

module.exports = {
    networkConfig, developmentChains
}