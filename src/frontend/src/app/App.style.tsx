import styled from 'styled-components/macro'
import { backgroundColorDark } from 'styles'

export const AppStyled = styled.div`
  display: flex;
  justify-content: space-around;
`
export const AppContainer = styled.div`
  min-height: 100vh;
`

export const AppBg = styled.div`
  position: fixed;
  top: 0;
  left: 0;
  min-width: 100vw;
  min-height: 100vh;
  background-color: ${backgroundColorDark};
  /* background-image: url('/images/bg.png');
  background-position: center;
  background-repeat: no-repeat;
  background-size: cover; */
`

export const AppWrapper = styled.div`
  position: absolute;
  width: 100vw;
  top: 0;
  background: url('/images/grid.svg') repeat center top;
  /* height: 100vh; */
  will-change: transform, opacity;
`
