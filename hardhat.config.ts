import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "@nomicfoundation/hardhat-verify";
import { load } from "ts-dotenv";

const env = load({
    INFURA_API_KEY: String,
    INFURA_SECRET_KEY: String,
    DEV_WALLET_PRIVATE_KEY: String,
    ETHERSCAN_API_KEY: String,
});

// To enable forking, turn one of these booleans on, and then run your tasks/scripts using ``--network hardhat``
// For more information go to the hardhat guide
// https://hardhat.org/hardhat-network/
// https://hardhat.org/guides/mainnet-forking.html
const FORK_FUJI = false;
const FORK_MAINNET = false;
const forkingData = FORK_FUJI
    ? {
          url: "https://api.avax-test.network/ext/bc/C/rpc",
      }
    : FORK_MAINNET
    ? {
          url: "https://api.avax.network/ext/bc/C/rpc",
      }
    : undefined;

const config: HardhatUserConfig = {
    solidity: {
        compilers: [
            {
                version: "0.8.20",
            },
        ],
    },

    networks: {
        sepolia: {
            url: `https://sepolia.infura.io/v3/${env.INFURA_API_KEY}`,
            accounts: [env.DEV_WALLET_PRIVATE_KEY],
        },
        neonDev: {  
            url: "https://devnet.neonevm.org",
            accounts: [env.DEV_WALLET_PRIVATE_KEY],
            chainId: 245022926,
        },
        // mainnet: {
        //   url: `https://mainnet.infura.io/v3/${env.INFURA_API_KEY}`,
        //   accounts: [env.TITAN_WALLET_PRIVATE_KEY]
        // },
        // spicy: {
        //     url: `https://spicy-rpc.chiliz.com/`,
        //     accounts: [env.DEV_WALLET_PRIVATE_KEY],
        // },
        // chiliz: {
        //   url: "https://rpc.ankr.com/chiliz",
        //   accounts: [env.WALLET_PRIVATE_KEY],
        //   chainId: 88888
        // },
        // fuji: {
        //     url: "https://api.avax-test.network/ext/bc/C/rpc",
        //     accounts: [env.DEV_WALLET_PRIVATE_KEY],
        //     chainId: 43113,
        //     gasPrice: 40000000000,
        // },
        // avalanche:{
        //   url: "https://api.avax.network/ext/bc/C/rpc",
        //   accounts: [env.WALLET_PRIVATE_KEY],
        //   chainId: 43114
        // }
        // artio: {
        //     url: "https://rpc.ankr.com/berachain_testnet",
        //     accounts: [env.DEV_WALLET_PRIVATE_KEY],
        //     chainId: 80085,
        //     gasPrice: 45000000000,
        // },
        // alfajores: {
        //   url: "https://alfajores-forno.celo-testnet.org",
        //   accounts: [env.DEV_WALLET_PRIVATE_KEY],
        //   chainId: 44787,
        //   gasPrice: 80000000000,
        // },
        katana: {
            url: "https://rpc.zkatana.gelato.digital",
            accounts: [env.DEV_WALLET_PRIVATE_KEY],
            chainId: 1261120,
            gasPrice: 70000000000,
        },
        hardhat: {
            gasPrice: 225000000000,
            chainId: !forkingData ? 43112 : undefined, //Only specify a chainId if we are not forking
            forking: forkingData,
            accounts: {
                mnemonic:
                    "test test test test test test test test test test test junk",
                accountsBalance: "10000000000000000000000000", // Set a higher default balance
            },
        },
    },

    etherscan: {
        apiKey: {
            sepolia: env.ETHERSCAN_API_KEY,
            mainnet: env.ETHERSCAN_API_KEY,
            spicy: env.ETHERSCAN_API_KEY,
            snowtrace: "snowtrace",
            fuji: "snowtrace",
            katana: "katana",
            neonDev: "neonDev",
        },
        customChains: [
            {
                network: "spicy",
                chainId: 88882,
                urls: {
                    apiURL: "",
                    browserURL: "http://spicy-explorer.chiliz.com/",
                },
            },
            {
                network: "fuji",
                chainId: 43113,
                urls: {
                    apiURL: "https://api.routescan.io/v2/network/testnet/evm/43113/etherscan",
                    browserURL: "https://avalanche.testnet.routescan.io",
                },
            },
            {
              network: "neonDev",
              chainId: 245022926,
              urls: {
                  apiURL: "https://devnet.neonscan.org/api",
                  browserURL: "https://devnet.neonscan.org",
              },
          },
          {
            network: "katana",
            chainId: 1261120,
            urls: {
              apiURL: "https://zkatana.blockscout.com/api",
              browserURL: "https://zkatana.blockscout.com"
            }
          },
          {
              network: "alfajores",
              chainId: 44787,
              urls: {
                apiURL: "https://api-alfajores.celoscan.io/api",
                browserURL: "https://alfajores.celoscan.io/"
              }
          }
        ],
    },
};

export default config;
