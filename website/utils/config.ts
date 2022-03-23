export const WEB3_APP_DISPLAY_NAME = '';

export const PRODUCTION_ROOT_URL = '';
export const PRODUCTION_ROOT_URLS = [PRODUCTION_ROOT_URL];

export const SUPPORTED_CHAIN_IDS = [1, 42, 3, 4];
export const DEFAULT_CHAIN_ID = 1; // dont commit

export const POLL_BLOCK_NUMBER_INTERVAL_MS = 60 * 1000;
export const ALCHEMY_RPC_KEY_MAINNET =
  process.env.NEXT_PUBLIC_ALCHEMY_RPC_KEY_MAINNET;

export const ALCHEMY_RPC_URL_MAINNET_HTTP = `https://eth-mainnet.alchemyapi.io/v2/${ALCHEMY_RPC_KEY_MAINNET}`;
export const ALCHEMY_RPC_URL_MAINNET_WSS = `wss://eth-mainnet.ws.alchemyapi.io/v2/${ALCHEMY_RPC_KEY_MAINNET}`;

export const ALCHEMY_RPC_KEY_KOVAN =
  process.env.NEXT_PUBLIC_ALCHEMY_RPC_KEY_KOVAN;

export const ALCHEMY_RPC_URL_KOVAN_HTTP = `https://eth-kovan.alchemyapi.io/v2/${ALCHEMY_RPC_KEY_KOVAN}`;
export const ALCHEMY_RPC_URL_KOVAN_WSS = `wss://eth-kovan.ws.alchemyapi.io/v2/${ALCHEMY_RPC_KEY_KOVAN}`;

export const ALCHEMY_RPC_KEY_ROPSTEN =
  process.env.NEXT_PUBLIC_ALCHEMY_RPC_KEY_KOVAN;
export const ALCHEMY_RPC_URL_ROPSTEN_HTTP = `https://eth-ropsten.alchemyapi.io/v2/${ALCHEMY_RPC_KEY_ROPSTEN}`;

export const RPC_URLS = {
  1: ALCHEMY_RPC_URL_MAINNET_HTTP,
  42: ALCHEMY_RPC_URL_KOVAN_HTTP,
  3: ALCHEMY_RPC_URL_ROPSTEN_HTTP,
};

export const DEFAULT_SCRIPT_LOAD_DEFER_TIME_IN_MS = 1200;

export const isProductionUrl = (): boolean => {
  const currentRootUrl = window.location.origin;
  const [isProductionUrl] = PRODUCTION_ROOT_URLS.map((url) =>
    currentRootUrl.includes(url),
  ).filter((x) => !!x);
  return isProductionUrl || false;
};

export const DEFER_MODULES_TIMINGS = {
  ALCHEMY_RPC: 2000,
  LIMIT_ORDER_WATCHER: 4000,
  LOG_EVENT_WATCHER: 20000,
};

export const getHttpRpcUrl = (chainId?: number): string => {
  switch (chainId) {
    case undefined:
      return getHttpRpcUrl(DEFAULT_CHAIN_ID);
    case 1:
      return ALCHEMY_RPC_URL_MAINNET_HTTP;
    case 3:
      return ALCHEMY_RPC_URL_ROPSTEN_HTTP;
    case 42:
      return ALCHEMY_RPC_URL_KOVAN_HTTP;
  }
  throw new Error(`unsupported chainId: ${chainId}`);
};

export const getAlchemyRpcKey = (chainId?: number): string => {
  switch (chainId) {
    case undefined:
      return getAlchemyRpcKey(DEFAULT_CHAIN_ID);
    case 1:
      return ALCHEMY_RPC_KEY_MAINNET!;
    case 3:
      return ALCHEMY_RPC_KEY_ROPSTEN!;
    case 42:
      return ALCHEMY_RPC_KEY_KOVAN!;
  }
  throw new Error(`unsupported chainId: ${chainId}`);
};
