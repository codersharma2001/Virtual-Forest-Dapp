require('@nomiclabs/hardhat-waffle');
require('@nomiclabs/hardhat-ethers');

module.exports = {
  solidity: '0.8.19',
  networks: {
    hardhat: {
      chainId: 1337,
    },
    polygon_testnet: {
      url: 'https://rpc-mumbai.maticvigil.com/', // Polygon Mumbai RPC URL
      chainId: 80001, // Polygon Mumbai chain ID
      accounts: {
        mnemonic: 'bundle onion banner utility canoe artist much lounge blossom lemon visit impose', // Replace with your mnemonic
      },
    
    },
  },
};

