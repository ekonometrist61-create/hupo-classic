import React from 'react';
import {Composition} from 'remotion';
import {HupoUyanir, TOPLAM_KARE} from './HupoUyanir';

export const Root: React.FC = () => (
  <Composition
    id="HupoUyanir"
    component={HupoUyanir}
    durationInFrames={TOPLAM_KARE}
    fps={30}
    width={1080}
    height={1920}
  />
);