import React from 'react';
import {Composition} from 'remotion';
import {HupoUyanir, TOPLAM_KARE} from './HupoUyanir';
import {HupoGelir, GELIR_TOPLAM} from './HupoGelir';
import {HupoUcar, UCAR_TOPLAM} from './HupoUcar';
import {HupoImza, IMZA_TOPLAM} from './HupoImza';

export const Root: React.FC = () => (
  <>
    <Composition id="HupoUyanir" component={HupoUyanir} durationInFrames={TOPLAM_KARE} fps={30} width={1080} height={1920} />
    <Composition id="HupoGelir" component={HupoGelir} durationInFrames={GELIR_TOPLAM} fps={30} width={1080} height={1920} />
    <Composition id="HupoUcar" component={HupoUcar} durationInFrames={UCAR_TOPLAM} fps={30} width={1080} height={1920} />
    <Composition id="HupoImza" component={HupoImza} durationInFrames={IMZA_TOPLAM} fps={60} width={1080} height={2340} />
  </>
);
