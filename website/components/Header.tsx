import React, { useCallback } from 'react';
import Link from 'next/link';
import styled from 'styled-components';

import { P } from '../components/Typography';
import { SecondaryButton } from '../components/Buttons';
import { routes } from '../utils/routes';
import { disableEagerWalletConnectPreference } from '../utils/preferences';
import { useWeb3React } from '@web3-react/core';
import { useClearWalletSession } from '../hooks/useClearWalletSession';

const Wrapper = styled.div`
  height: 100px;
  margin: 20px;
  display: flex;
  flex-direction: row;
  justify-content: space-between;
  align-items: center;
`;

const LoginWrapper = styled.div``;

const LogoImg = styled.img`
  height: 100%;
`;

const StyledSecondaryButton = styled(SecondaryButton)`
  padding: 0 20px;
`;

const Logo: React.FC = React.memo(() => (
  <LogoImg src={require('../images/logo.png')} />
));

export const Header = () => {
  const { account } = useWeb3React();
  const { clearSession } = useClearWalletSession();

  const handleDisconnectAccount = useCallback(() => {
    disableEagerWalletConnectPreference();
    clearSession();
  }, [clearSession]);
  return (
    <Wrapper>
      <Logo />
      <LoginWrapper>
        {account ? (
          <>
            <StyledSecondaryButton
              style={{ maxWidth: '300px' }}
              onClick={handleDisconnectAccount}
            >
              Disconnect Wallet
            </StyledSecondaryButton>
          </>
        ) : (
          <Link passHref href={routes.LOGIN}>
            <StyledSecondaryButton style={{ maxWidth: '300px' }}>
              Connect Wallet
            </StyledSecondaryButton>
          </Link>
        )}
      </LoginWrapper>
    </Wrapper>
  );
};
