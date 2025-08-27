include .env
export

DEPLOYER_ADDRESS := $(shell cast wallet address --account ${ACCOUNT_NAME} --password ${PASSWORD})

.PHONY: clear-usdt-deployments
clear-usdt-deployments:
	python3 -m venv ".clear-usdt-deployments"
	./.clear-usdt-deployments/bin/python -m pip install --upgrade pip
	./.clear-usdt-deployments/bin/python -m pip install tomli tomli-w dotenv
	./.clear-usdt-deployments/bin/python ./script/ClearDeploymentsFromConfig.py usdt
	rm -rf ./.clear-usdt-deployments

.PHONY: usdt-deploy
usdt-deploy: clear-usdt-deployments
	forge script ./script/usdt/deploy/01_USDTDeploy.s.sol --sender $(DEPLOYER_ADDRESS) --account $(ACCOUNT_NAME) --password $(PASSWORD) --broadcast
	@echo "✅ USDT deployment steps completed successfully!"

.PHONY: usdt-bridge-deploy
usdt-bridge-deploy:
	forge script ./script/usdt/deploy/02_USDTBridgeDeploy.s.sol --sender $(DEPLOYER_ADDRESS) --account $(ACCOUNT_NAME) --password $(PASSWORD) --broadcast

.PHONY: usdt-src-bridge-set-lz-config
usdt-src-bridge-set-lz-config:
	forge script ./script/usdt/deploy/03_USDTSrcBridgeSetLzConfig.s.sol --sender $(DEPLOYER_ADDRESS) --account $(ACCOUNT_NAME) --password $(PASSWORD) --broadcast

.PHONY: usdt-dest-bridge-set-lz-config
usdt-dest-bridge-set-lz-config:
	forge script ./script/usdt/deploy/04_USDTDestBridgeSetLzConfig.s.sol --sender $(DEPLOYER_ADDRESS) --account $(ACCOUNT_NAME) --password $(PASSWORD) --broadcast

.PHONY: usdt-src-bridge-set-peer
usdt-src-bridge-set-peer:
	forge script ./script/usdt/deploy/05_USDTSrcBridgeSetPeer.s.sol --sender $(DEPLOYER_ADDRESS) --account $(ACCOUNT_NAME) --password $(PASSWORD) --broadcast

.PHONY: usdt-dest-bridge-set-peer
usdt-dest-bridge-set-peer:
	forge script ./script/usdt/deploy/06_USDTDestBridgeSetPeer.s.sol --sender $(DEPLOYER_ADDRESS) --account $(ACCOUNT_NAME) --password $(PASSWORD) --broadcast

.PHONY: usdt-set-bridge-as-minter
usdt-set-bridge-as-minter:
	forge script ./script/usdt/deploy/07_USDTSetBridgeAsMinter.s.sol --sender $(DEPLOYER_ADDRESS) --account $(ACCOUNT_NAME) --password $(PASSWORD) --broadcast

.PHONY: usdt-and-bridge-assign-roles
usdt-and-bridge-assign-roles:
	forge script ./script/usdt/deploy/08_USDTAndBridgeAssignRoles.s.sol --sender $(DEPLOYER_ADDRESS) --account $(ACCOUNT_NAME) --password $(PASSWORD) --broadcast

.PHONY: usdt-bridge-post-deployment-test
usdt-bridge-post-deployment-test:
	IS_POST_DEPLOYMENT=true forge test --match-path test/usdt/post_deployment/USDTPostDeployment.t.sol

.PHONY: usdt-bridge-full
usdt-bridge-full: usdt-bridge-deploy usdt-src-bridge-set-lz-config usdt-dest-bridge-set-lz-config usdt-src-bridge-set-peer usdt-dest-bridge-set-peer usdt-set-bridge-as-minter usdt-and-bridge-assign-roles usdt-bridge-post-deployment-test
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

.PHONY: usdc-bridge-deploy
usdc-bridge-deploy:
	forge script ./script/usdc/deploy/02_USDCBridgeDeploy.s.sol --sender $(DEPLOYER_ADDRESS) --account $(ACCOUNT_NAME) --password $(PASSWORD) --broadcast

.PHONY: usdc-src-bridge-set-lz-config
usdc-src-bridge-set-lz-config:
	forge script ./script/usdc/deploy/03_USDCSrcBridgeSetLzConfig.s.sol --sender $(DEPLOYER_ADDRESS) --account $(ACCOUNT_NAME) --password $(PASSWORD) --broadcast

.PHONY: usdc-dest-bridge-set-lz-config
usdc-dest-bridge-set-lz-config:
	forge script ./script/usdc/deploy/04_USDCDestBridgeSetLzConfig.s.sol --sender $(DEPLOYER_ADDRESS) --account $(ACCOUNT_NAME) --password $(PASSWORD) --broadcast

.PHONY: usdc-src-bridge-set-peer
usdc-src-bridge-set-peer:
	forge script ./script/usdc/deploy/05_USDCSrcBridgeSetPeer.s.sol --sender $(DEPLOYER_ADDRESS) --account $(ACCOUNT_NAME) --password $(PASSWORD) --broadcast

.PHONY: usdc-dest-bridge-set-peer
usdc-dest-bridge-set-peer:
	forge script ./script/usdc/deploy/06_USDCDestBridgeSetPeer.s.sol --sender $(DEPLOYER_ADDRESS) --account $(ACCOUNT_NAME) --password $(PASSWORD) --broadcast

.PHONY: usdc-set-bridge-as-minter
usdc-set-bridge-as-minter:
	forge script ./script/usdc/deploy/07_USDCSetBridgeAsMinter.s.sol --sender $(DEPLOYER_ADDRESS) --account $(ACCOUNT_NAME) --password $(PASSWORD) --broadcast

.PHONY: usdc-and-bridge-assign-roles
usdc-and-bridge-assign-roles:
	forge script ./script/usdc/deploy/08_USDCAndBridgeAssignRoles.s.sol --sender $(DEPLOYER_ADDRESS) --account $(ACCOUNT_NAME) --password $(PASSWORD) --broadcast

.PHONY: usdc-bridge-post-deployment-test
usdc-bridge-post-deployment-test:
	IS_POST_DEPLOYMENT=true forge test --match-path test/usdc/post_deployment/USDCPostDeployment.t.sol

.PHONY: usdc-bridge-full
usdc-bridge-full: usdc-bridge-deploy usdc-src-bridge-set-lz-config usdc-dest-bridge-set-lz-config usdc-src-bridge-set-peer usdc-dest-bridge-set-peer usdc-set-bridge-as-minter usdc-and-bridge-assign-roles usdc-bridge-post-deployment-test
	@echo "✅ All USDC bridge deployment steps completed successfully!"

usdc-and-bridge: usdc-deploy usdc-bridge-full
	@echo "✅ All USDC and bridge deployment steps completed successfully!"

usdc-bridge-mint-test:
	forge script ./script/usdc/test/USDCBridgeMintTest.s.sol --sender $(DEPLOYER_ADDRESS) --account $(ACCOUNT_NAME) --password $(PASSWORD) --broadcast

usdc-bridge-burn-test:
	forge script ./script/usdc/test/USDCBridgeBurnTest.s.sol  --sender $(DEPLOYER_ADDRESS) --account $(ACCOUNT_NAME) --password $(PASSWORD) --broadcast
