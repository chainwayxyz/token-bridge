include .env
export

DEPLOYER_ADDRESS := $(shell cast wallet address --account ${ACCOUNT_NAME} --password ${PASSWORD})
DEST_VERIFIER := $(shell \
	value=$$(yq '.dest.verifier' "./config/${NETWORK}/config.toml"); \
	if [ "$$value" = "etherscan" ]; then \
		echo "custom"; \
	else \
		echo "$$value"; \
	fi)

SRC_VERIFIER := $(shell \
	value=$$(yq '.src.verifier' "./config/${NETWORK}/config.toml"); \
	if [ "$$value" = "etherscan" ]; then \
		echo "custom"; \
	else \
		echo "$$value"; \
	fi)

DEST_VERIFIER_URL = $(shell yq '.dest.verifierUrl' "./config/${NETWORK}/config.toml")
SRC_VERIFIER_URL := $(shell yq '.src.verifierUrl' "./config/${NETWORK}/config.toml")

DEST_VERIFIER_API_KEY_FLAG := $(if $(DEST_VERIFIER_API_KEY),--verifier-api-key $(DEST_VERIFIER_API_KEY))
SRC_VERIFIER_API_KEY_FLAG := $(if $(SRC_VERIFIER_API_KEY),--verifier-api-key $(SRC_VERIFIER_API_KEY))

.PHONY: clear-usdt-deployments
clear-usdt-deployments:
	python3 -m venv ".clear-usdt-deployments"
	./.clear-usdt-deployments/bin/python -m pip install --upgrade pip
	./.clear-usdt-deployments/bin/python -m pip install tomli tomli-w dotenv
	./.clear-usdt-deployments/bin/python ./script/ClearDeploymentsFromConfig.py usdt
	rm -rf ./.clear-usdt-deployments

.PHONY: usdt-deploy
usdt-deploy: clear-usdt-deployments
	forge script ./script/usdt/deploy/01_USDTDeploy.s.sol --sender $(DEPLOYER_ADDRESS) --account $(ACCOUNT_NAME) --password $(PASSWORD) --broadcast --verify --verifier $(DEST_VERIFIER) --verifier-url $(DEST_VERIFIER_URL) $(DEST_VERIFIER_API_KEY_FLAG)
	@echo "✅ USDT deployment steps completed successfully!"

.PHONY: usdt-src-bridge-deploy
usdt-src-bridge-deploy:
	forge script ./script/usdt/deploy/02_USDTSrcBridgeDeploy.s.sol --sender $(DEPLOYER_ADDRESS) --account $(ACCOUNT_NAME) --password $(PASSWORD) --broadcast --verify --verifier $(SRC_VERIFIER) --verifier-url $(SRC_VERIFIER_URL) $(SRC_VERIFIER_API_KEY_FLAG)

.PHONY: usdt-dest-bridge-deploy
usdt-dest-bridge-deploy:
	forge script ./script/usdt/deploy/03_USDTDestBridgeDeploy.s.sol --sender $(DEPLOYER_ADDRESS) --account $(ACCOUNT_NAME) --password $(PASSWORD) --broadcast --verify --verifier $(DEST_VERIFIER) --verifier-url $(DEST_VERIFIER_URL) $(DEST_VERIFIER_API_KEY_FLAG)

.PHONY: usdt-src-bridge-set-lz-config
usdt-src-bridge-set-lz-config:
	forge script ./script/usdt/deploy/04_USDTSrcBridgeSetLzConfig.s.sol --sender $(DEPLOYER_ADDRESS) --account $(ACCOUNT_NAME) --password $(PASSWORD) --broadcast

.PHONY: usdt-dest-bridge-set-lz-config
usdt-dest-bridge-set-lz-config:
	forge script ./script/usdt/deploy/05_USDTDestBridgeSetLzConfig.s.sol --sender $(DEPLOYER_ADDRESS) --account $(ACCOUNT_NAME) --password $(PASSWORD) --broadcast

.PHONY: usdt-set-bridge-as-minter
usdt-set-bridge-as-minter:
	forge script ./script/usdt/deploy/06_USDTSetBridgeAsMinter.s.sol --sender $(DEPLOYER_ADDRESS) --account $(ACCOUNT_NAME) --password $(PASSWORD) --broadcast

.PHONY: usdt-dest-bridge-set-peer
usdt-dest-bridge-set-peer:
	forge script ./script/usdt/deploy/07_USDTDestBridgeSetPeer.s.sol --sender $(DEPLOYER_ADDRESS) --account $(ACCOUNT_NAME) --password $(PASSWORD) --broadcast

.PHONY: usdt-src-bridge-set-peer
usdt-src-bridge-set-peer:
	forge script ./script/usdt/deploy/08_USDTSrcBridgeSetPeer.s.sol --sender $(DEPLOYER_ADDRESS) --account $(ACCOUNT_NAME) --password $(PASSWORD) --broadcast

.PHONY: usdt-and-bridge-assign-roles
usdt-and-bridge-assign-roles:
	forge script ./script/usdt/deploy/09_USDTAndBridgeAssignRoles.s.sol --sender $(DEPLOYER_ADDRESS) --account $(ACCOUNT_NAME) --password $(PASSWORD) --broadcast

.PHONY: usdt-bridge-post-deployment-test
usdt-bridge-post-deployment-test:
	IS_POST_DEPLOYMENT=true forge test --match-path test/usdt/post_deployment/USDTPostDeployment.t.sol

.PHONY: usdt-bridge-full
usdt-bridge-full: usdt-src-bridge-deploy usdt-dest-bridge-deploy usdt-src-bridge-set-lz-config usdt-dest-bridge-set-lz-config usdt-set-bridge-as-minter usdt-dest-bridge-set-peer usdt-src-bridge-set-peer usdt-and-bridge-assign-roles usdt-bridge-post-deployment-test
	@echo "✅ All USDT bridge deployment steps completed successfully!"

usdt-and-bridge: usdt-deploy usdt-bridge-full
	@echo "✅ All USDT and bridge deployment steps completed successfully!"

usdt-bridge-mint-test:
	forge script ./script/usdt/test/USDTBridgeMintTest.s.sol --sender $(DEPLOYER_ADDRESS) --account $(ACCOUNT_NAME) --password $(PASSWORD) --broadcast

usdt-bridge-burn-test:
	forge script ./script/usdt/test/USDTBridgeBurnTest.s.sol --sender $(DEPLOYER_ADDRESS) --account $(ACCOUNT_NAME) --password $(PASSWORD) --broadcast

.PHONY: clear-usdc-deployments
clear-usdc-deployments:
	python3 -m venv ".clear-usdc-deployments"
	./.clear-usdc-deployments/bin/python -m pip install --upgrade pip
	./.clear-usdc-deployments/bin/python -m pip install tomli tomli-w dotenv
	./.clear-usdc-deployments/bin/python ./script/ClearDeploymentsFromConfig.py usdc
	rm -rf ./.clear-usdc-deployments

.PHONY: usdc-deploy
usdc-deploy: clear-usdc-deployments
	./script/usdc/deploy/01_USDCDeploy.sh
	@echo "✅ USDC deployment steps completed successfully!"

.PHONY: usdc-src-bridge-deploy
usdc-src-bridge-deploy:
	forge script ./script/usdc/deploy/02_USDCSrcBridgeDeploy.s.sol --sender $(DEPLOYER_ADDRESS) --account $(ACCOUNT_NAME) --password $(PASSWORD) --broadcast  --verify --verifier $(SRC_VERIFIER) --verifier-url $(SRC_VERIFIER_URL) $(SRC_VERIFIER_API_KEY_FLAG)

.PHONY: usdc-dest-bridge-deploy
usdc-dest-bridge-deploy:
	forge script ./script/usdc/deploy/03_USDCDestBridgeDeploy.s.sol --sender $(DEPLOYER_ADDRESS) --account $(ACCOUNT_NAME) --password $(PASSWORD) --broadcast --verify --verifier $(DEST_VERIFIER) --verifier-url $(DEST_VERIFIER_URL) $(DEST_VERIFIER_API_KEY_FLAG)

.PHONY: usdc-src-bridge-set-lz-config
usdc-src-bridge-set-lz-config:
	forge script ./script/usdc/deploy/04_USDCSrcBridgeSetLzConfig.s.sol --sender $(DEPLOYER_ADDRESS) --account $(ACCOUNT_NAME) --password $(PASSWORD) --broadcast

.PHONY: usdc-dest-bridge-set-lz-config
usdc-dest-bridge-set-lz-config:
	forge script ./script/usdc/deploy/05_USDCDestBridgeSetLzConfig.s.sol --sender $(DEPLOYER_ADDRESS) --account $(ACCOUNT_NAME) --password $(PASSWORD) --broadcast

.PHONY: usdc-set-bridge-as-minter
usdc-set-bridge-as-minter:
	forge script ./script/usdc/deploy/06_USDCSetBridgeAsMinter.s.sol --sender $(DEPLOYER_ADDRESS) --account $(ACCOUNT_NAME) --password $(PASSWORD) --broadcast

.PHONY: usdc-dest-bridge-set-peer
usdc-dest-bridge-set-peer:
	forge script ./script/usdc/deploy/07_USDCDestBridgeSetPeer.s.sol --sender $(DEPLOYER_ADDRESS) --account $(ACCOUNT_NAME) --password $(PASSWORD) --broadcast

.PHONY: usdc-src-bridge-set-peer
usdc-src-bridge-set-peer:
	forge script ./script/usdc/deploy/08_USDCSrcBridgeSetPeer.s.sol --sender $(DEPLOYER_ADDRESS) --account $(ACCOUNT_NAME) --password $(PASSWORD) --broadcast

.PHONY: usdc-and-bridge-assign-roles
usdc-and-bridge-assign-roles:
	forge script ./script/usdc/deploy/09_USDCAndBridgeAssignRoles.s.sol --sender $(DEPLOYER_ADDRESS) --account $(ACCOUNT_NAME) --password $(PASSWORD) --broadcast

.PHONY: usdc-bridge-post-deployment-test
usdc-bridge-post-deployment-test:
	IS_POST_DEPLOYMENT=true forge test --match-path test/usdc/post_deployment/USDCPostDeployment.t.sol

.PHONY: usdc-bridge-full
usdc-bridge-full: usdc-src-bridge-deploy usdc-dest-bridge-deploy usdc-src-bridge-set-lz-config usdc-dest-bridge-set-lz-config usdc-set-bridge-as-minter usdc-dest-bridge-set-peer usdc-src-bridge-set-peer usdc-and-bridge-assign-roles usdc-bridge-post-deployment-test
	@echo "✅ All USDC bridge deployment steps completed successfully!"

usdc-and-bridge: usdc-deploy usdc-bridge-full
	@echo "✅ All USDC and bridge deployment steps completed successfully!"

usdc-bridge-mint-test:
	forge script ./script/usdc/test/USDCBridgeMintTest.s.sol --sender $(DEPLOYER_ADDRESS) --account $(ACCOUNT_NAME) --password $(PASSWORD) --broadcast

usdc-bridge-burn-test:
	forge script ./script/usdc/test/USDCBridgeBurnTest.s.sol  --sender $(DEPLOYER_ADDRESS) --account $(ACCOUNT_NAME) --password $(PASSWORD) --broadcast

.PHONY: clear-wbtc-deployments
clear-wbtc-deployments:
	python3 -m venv ".clear-wbtc-deployments"
	./.clear-wbtc-deployments/bin/python -m pip install --upgrade pip
	./.clear-wbtc-deployments/bin/python -m pip install tomli tomli-w dotenv
	./.clear-wbtc-deployments/bin/python ./script/ClearDeploymentsFromConfig.py wbtc
	rm -rf ./.clear-wbtc-deployments

.PHONY: wbtc-src-bridge-deploy
wbtc-src-bridge-deploy: clear-wbtc-deployments
	forge script ./script/wbtc/deploy/01_WBTCSrcBridgeDeploy.s.sol --sender $(DEPLOYER_ADDRESS) --account $(ACCOUNT_NAME) --password $(PASSWORD) --broadcast --verify --verifier $(SRC_VERIFIER) --verifier-url $(SRC_VERIFIER_URL) $(SRC_VERIFIER_API_KEY_FLAG)

.PHONY: wbtc-dest-bridge-deploy
wbtc-dest-bridge-deploy:
	forge script ./script/wbtc/deploy/02_WBTCDestBridgeDeploy.s.sol --sender $(DEPLOYER_ADDRESS) --account $(ACCOUNT_NAME) --password $(PASSWORD) --broadcast --verify --verifier $(DEST_VERIFIER) --verifier-url $(DEST_VERIFIER_URL) $(DEST_VERIFIER_API_KEY_FLAG)

.PHONY: wbtc-src-bridge-set-lz-config
wbtc-src-bridge-set-lz-config:
	forge script ./script/wbtc/deploy/03_WBTCSrcBridgeSetLzConfig.s.sol --sender $(DEPLOYER_ADDRESS) --account $(ACCOUNT_NAME) --password $(PASSWORD) --broadcast

.PHONY: wbtc-dest-bridge-set-lz-config
wbtc-dest-bridge-set-lz-config:
	forge script ./script/wbtc/deploy/04_WBTCDestBridgeSetLzConfig.s.sol --sender $(DEPLOYER_ADDRESS) --account $(ACCOUNT_NAME) --password $(PASSWORD) --broadcast

.PHONY: wbtc-dest-bridge-set-peer
wbtc-dest-bridge-set-peer:
	forge script ./script/wbtc/deploy/05_WBTCDestBridgeSetPeer.s.sol --sender $(DEPLOYER_ADDRESS) --account $(ACCOUNT_NAME) --password $(PASSWORD) --broadcast

.PHONY: wbtc-src-bridge-set-peer
wbtc-src-bridge-set-peer:
	forge script ./script/wbtc/deploy/06_WBTCSrcBridgeSetPeer.s.sol --sender $(DEPLOYER_ADDRESS) --account $(ACCOUNT_NAME) --password $(PASSWORD) --broadcast

.PHONY: wbtc-and-bridge-assign-roles
wbtc-and-bridge-assign-roles:
	forge script ./script/wbtc/deploy/07_WBTCAndBridgeAssignRoles.s.sol --sender $(DEPLOYER_ADDRESS) --account $(ACCOUNT_NAME) --password $(PASSWORD) --broadcast

.PHONY: wbtc-bridge-post-deployment-test
wbtc-bridge-post-deployment-test:
	IS_POST_DEPLOYMENT=true forge test --match-path test/wbtc/post_deployment/WBTCPostDeployment.t.sol

.PHONY: wbtc-bridge-full
wbtc-bridge-full: wbtc-src-bridge-deploy wbtc-dest-bridge-deploy wbtc-src-bridge-set-lz-config wbtc-dest-bridge-set-lz-config wbtc-dest-bridge-set-peer wbtc-src-bridge-set-peer wbtc-and-bridge-assign-roles wbtc-bridge-post-deployment-test
	@echo "✅ All WBTC bridge deployment steps completed successfully!"

wbtc-bridge-mint-test:
	forge script ./script/wbtc/test/WBTCBridgeMintTest.s.sol --sender $(DEPLOYER_ADDRESS) --account $(ACCOUNT_NAME) --password $(PASSWORD) --broadcast

wbtc-bridge-burn-test:
	forge script ./script/wbtc/test/WBTCBridgeBurnTest.s.sol --sender $(DEPLOYER_ADDRESS) --account $(ACCOUNT_NAME) --password $(PASSWORD) --broadcast
