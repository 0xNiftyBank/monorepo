import React from 'react';
import { NextPage } from 'next';

import { H1 } from '../components/Typography';
import { PageContainer } from '../components/Layout';

const HomePage: NextPage = () => {
  return (
    <>
      <PageContainer style={{ position: 'relative' }} id="top">
        <H1>Hello World</H1>
      </PageContainer>
    </>
  );
};

const MemoizedHomePage = React.memo(HomePage);
export default MemoizedHomePage;
