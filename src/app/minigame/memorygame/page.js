'use client'

import Head from 'next/head';
import CirclesContainer from '../../../components/Circle';
import '../../globals.css';

export default function memorygame() {
  return (
    <div id="container">
        <Head>
            <title>REACT! REACT! REACT!</title>
            <link rel="stylesheet" href="styles/globals.css" />
        </Head>
        <CirclesContainer />
    </div>
  );
}