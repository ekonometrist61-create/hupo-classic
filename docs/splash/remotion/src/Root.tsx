import React from 'react';
import {Composition} from 'remotion';
import {HupoUyanir, TOPLAM_KARE} from './HupoUyanir';
import {HupoGelir, GELIR_TOPLAM} from './HupoGelir';

export const Root: React.FC = () => (
  <>
    <Composition id="HupoUyanir" component={HupoUyanir} durationInFrames={TOPLAM_KARE} fps={30} width={1080} height={1920} />
    <Composition id="HupoGelir" component={HupoGelir} durationInFrames={GELIR_TOPLAM} fps={30} width={1080} height={1920} />
  </>
);
