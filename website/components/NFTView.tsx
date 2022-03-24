import React, { FC, useEffect, useState } from 'react';
import styled from 'styled-components';
import Link, { LinkProps } from 'next/link';
import { getERC721MetadataAsync } from '../utils/nfts';
import { InjectedConnector } from '@web3-react/injected-connector';
import { SUPPORTED_CHAIN_IDS } from '../utils/config';
import { injected } from '../utils/web3/connector-instances';
import { Provider, Web3Provider } from '@ethersproject/providers';
import { resolveUrl } from '../utils/ipfs';

export const StyledLink = styled.a`
  font-family: 'Khula';
  font-weight: ${(props) => props.theme.fontWeights.semiBold};
  font-size: inherit;
  line-height: 140%;
  color: #333b4e;
  text-decoration: none;

  :hover,
  :active {
    text-decoration: underline;
  }

  @media (max-width: ${(props) => props.theme.breakpoints.md}) {
    font-size: 14px;
  }
`;

export const StyledFrame = styled.div`
  width: 200px;
`;

interface NFTViewProps {
  contract: string;
  tokenId: number;
}

export const NFTView: FC<NFTViewProps> = ({
  children,
  contract,
  tokenId,
  ...rest
}) => {
  const [metadata, setMetadata] = useState({ name: '', image: '' });

  // Fetch and render metadata
  useEffect(() => {
    injected.getProvider().then((provider) => {
      console.log(provider);
      const ethersProvider = new Web3Provider(provider);
      getERC721MetadataAsync(contract, tokenId, ethersProvider).then(
        (metadata) => {
          setMetadata(metadata);
        },
      );
    });
  }, []);

  return (
    <div>
      {metadata && (
        <div style={{}}>
          <div style={{ display: 'flex' }}>
            <div style={{ width: 200, display: 'flex' }}>
              <img src={resolveUrl(metadata.image)} />
            </div>
            <p>{metadata.name || tokenId}</p>
          </div>
        </div>
      )}
    </div>
  );
};
