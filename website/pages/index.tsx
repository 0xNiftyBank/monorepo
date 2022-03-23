import React from 'react';
import { NextPage } from 'next';
import Link from 'next/link';
import styled from 'styled-components';

import { P } from '../components/Typography';
import { PageContainer } from '../components/Layout';
import { SecondaryButton } from '../components/Buttons';

const StyledSecondaryButton = styled(SecondaryButton)`
  padding: 0 20px;
  width: 200px;
`;

const ButtonContainer = styled.div`
  width: 80%;
  max-width: 768px;
  display: flex;
  justify-content: space-between;
  margin: auto;
`;

const NavItem = styled.div`
  max-width: 200px;
  text-align: center;
`;
const HomePage: NextPage = () => {
  return (
    <>
      <PageContainer style={{ position: 'relative' }} id="top">
        <ButtonContainer>
          <NavItem>
            <Link passHref href="/borrow">
              <StyledSecondaryButton>Borrow</StyledSecondaryButton>
            </Link>
            <P style={{ marginTop: '10px' }}>
              Borrow USDC against your NFTs for a limited period of time and a
              known fixed fee
            </P>
          </NavItem>
          <NavItem>
            <Link passHref href="/lend">
              <StyledSecondaryButton>Lend</StyledSecondaryButton>
            </Link>
            <P style={{ marginTop: '10px' }}>
              Lend USDC against NFTs as collateral and gain a fixed rate fee or
              sub-floor NFT
            </P>
          </NavItem>
        </ButtonContainer>
      </PageContainer>
    </>
  );
};

const MemoizedHomePage = React.memo(HomePage);
export default MemoizedHomePage;
