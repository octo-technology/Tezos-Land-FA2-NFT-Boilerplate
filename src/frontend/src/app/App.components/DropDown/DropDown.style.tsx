import styled, { keyframes } from 'styled-components/macro'

import {
  backgroundColorDark,
  borderColor,
  downColor,
  primaryColor,
  upColor,
  backgroundTextColor,
} from '../../../styles'

export const DropDownStyled = styled("div")`
width: 10.5em;
margin: 0 auto;
`;

export const DropDownHeader = styled("div")`
width: 100%;
  display: block;
  position: relative;
  height: 40px;
  padding: 12px 16px 12px 40px;
  border-width: 1px;
  border-style: solid;
  border-color: ${borderColor};
  border-radius: 4px;
  transition: border-color 0.3s ease-in-out, box-shadow 0.3s ease-in-out;
  will-change: border-color, box-shadow;
  background-color: ${backgroundColorDark};
`;

export const DropDownListContainer = styled("div")``;

export const DropDownList = styled("ul")`
width: 100%;
  display: block;
  position: relative;
  height: 150px;
  padding: 12px 16px 12px 40px;
  border-width: 1px;
  border-style: solid;
  border-color: ${borderColor};
  border-radius: 4px;
  transition: border-color 0.3s ease-in-out, box-shadow 0.3s ease-in-out;
  will-change: border-color, box-shadow;
  background-color: ${backgroundColorDark};
  font-weight: 500;
  &:first-child {
    padding-top: 0.8em;
  }
`;

export const DropDownListItem = styled("li")`
  list-style: none;
  margin-bottom: 0.8em;
`;
