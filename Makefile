.PHONY: usdt-deploy usdt-bridge-deploy usdt-src-bridge-set-peer usdt-dest-bridge-set-peer usdt-set-bridge-as-minter usdt

include .env
export

usdt-deploy:
	forge script ./script/usdt/deploy/01_USDTDeploy.s.sol --account DEPLOYER --password $(PASSWORD) --broadcast

usdt-bridge-deploy:
	forge script ./script/usdt/deploy/02_USDTBridgeDeploy.s.sol --account DEPLOYER --password $(PASSWORD) --broadcast
	
usdt-src-bridge-set-peer:
	forge script ./script/usdt/deploy/03_USDTSrcBridgeSetPeer.s.sol --account DEPLOYER --password $(PASSWORD) --broadcast

usdt-dest-bridge-set-peer:
	forge script ./script/usdt/deploy/04_USDTDestBridgeSetPeer.s.sol --account DEPLOYER --password $(PASSWORD) --broadcast

usdt-set-bridge-as-minter:
	forge script ./script/usdt/deploy/05_USDTSetBridgeAsMinter.s.sol --account DEPLOYER --password $(PASSWORD) --broadcast

usdt: usdt-deploy usdt-bridge-deploy usdt-src-bridge-set-peer usdt-dest-bridge-set-peer usdt-set-bridge-as-minter
	@echo "✅ All USDT deployment steps completed successfully!"

usdt-bridge-mint-test:
	forge script ./script/usdt/test/USDTBridgeMintTest.s.sol --account DEPLOYER --password $(PASSWORD) --broadcast

usdt-bridge-burn-test:
	forge script ./script/usdt/test/USDTBridgeBurnTest.s.sol --account DEPLOYER --password $(PASSWORD) --broadcast
