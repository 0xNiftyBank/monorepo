import { Contract } from '@ethersproject/contracts';
import { Provider } from '@ethersproject/providers';
import { ERC721Metadata } from '../types/nfts';
import { resolveUrl } from './ipfs';

/**
 * Returns the ERC-721 Metadata for a given address and tokenId - requires a provider
 *
 * @param address
 * @param tokenId
 * @param provider
 * @returns
 */
export const getERC721MetadataAsync = async (
  address: string,
  tokenId: number,
  provider: Provider,
): Promise<ERC721Metadata> => {
  const ERC721Abi = [
    {
      inputs: [],
      name: 'name',
      outputs: [
        {
          internalType: 'string',
          name: '',
          type: 'string',
        },
      ],
      stateMutability: 'view',
      type: 'function',
    },
    {
      inputs: [
        {
          name: 'tokenId',
          type: 'uint256',
        },
      ],
      name: 'tokenURI',
      outputs: [
        {
          name: '_tokenURI',
          type: 'string',
        },
      ],
      stateMutability: 'view',
      type: 'function',
    },
  ];
  const tokenContract = new Contract(address, ERC721Abi, provider);
  const [url, name] = await Promise.all([
    tokenContract.tokenURI(tokenId),
    tokenContract.name(),
  ]);
  const ipfsFriendlyUrl = resolveUrl(url);
  const res = await fetch(ipfsFriendlyUrl);
  const metadata = await res.json();
  const fallbackName = `${name} #${tokenId}`;
  return {
    ...metadata,
    name: metadata.name || fallbackName,
  };
};
