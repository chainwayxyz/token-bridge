import tomli
import tomli_w
import os
import dotenv
import sys

dotenv.load_dotenv()
NETWORK = os.getenv('NETWORK')
if NETWORK != 'testnet' and NETWORK != 'mainnet':
    raise ValueError("NETWORK must be either 'testnet' or 'mainnet'")

CONFIG_PATH = f"./config/{NETWORK}/config.toml"

# Read the TOML file
with open(CONFIG_PATH, 'rb') as f:
    config = tomli.load(f)

# Reset all deployment addresses
def reset_deployment_addresses(section, tokenName, path=""):
    for key, value in section.items():
        current_path = f"{path}.{key}" if path else key
        if isinstance(value, dict):
            if current_path.endswith('.deployment') and tokenName in current_path:
                for addr_key, addr_value in value.items():
                    if isinstance(addr_value, str) and addr_value.startswith('0x'):
                        value[addr_key] = ''
            else:
                reset_deployment_addresses(value, tokenName, current_path)

# Get the second argument from the command line
if len(sys.argv) < 2:
    raise ValueError("Please provide the token name as the second argument.")
token_name = sys.argv[1]
reset_deployment_addresses(config, token_name)

# Write back to file
with open(CONFIG_PATH, 'wb') as f:
    tomli_w.dump(config, f)