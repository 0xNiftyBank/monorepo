import React from 'react';
import { NextPage } from 'next';

import { H1 } from '../components/Typography';
import { PageContainer } from '../components/Layout';
import { NFTView } from '../components/NFTView';

const HomePage: NextPage = () => {
  return (
    <>
      <PageContainer style={{ position: 'relative' }} id="top">
        <H1> Hello Borrower</H1>
        <NFTView
          contract="0xbc4ca0eda7647a8ab7c2061c2e118a18a936f13d"
          tokenId={100}
          floorPriceInEth={'101'}
          loanDueAt={new Date()}
        ></NFTView>
      </PageContainer>
    </>
  );
};

const MemoizedHomePage = React.memo(HomePage);
export default MemoizedHomePage;
