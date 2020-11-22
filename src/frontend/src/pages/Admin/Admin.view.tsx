import * as React from 'react'
import { DropDown } from 'app/App.components/DropDown/DropDown.controller'
import { Input } from 'app/App.components/Input/Input.controller'
import { HomeButton, HomeButtonBorder, HomeButtonText } from 'pages/Home/Home.style'
import { useState } from 'react'
type AdminViewProps = {
  mint: ({}: any) => void
  connectedUser: string
}


export const AdminView = ({ mint, connectedUser }: AdminViewProps) => {
  const values: ReadonlyArray<string> = ["Road", "Land", "Water", "Plaza", "District"];
  const [tokenId, setTokenId] = useState<string>('1');
  const [isOpen, setOpen] = useState(false)
  const [itemSelected, setItemSelected] = useState(values[0])
  const clickItem = (value: string) => {
      setItemSelected(value)
      setOpen(!isOpen)
  }
  const clickCallback = () => {
    setOpen(!isOpen)
  }
  const test: boolean = true
  return (
    <>
        <DropDown
          onChange={() => {}}
          onBlur={() => {}}
          icon="sell"
          items={values}
          isOpen={isOpen}
          itemSelected={itemSelected}
          clickOnDropDown={clickCallback}
          clickOnItem={clickItem}
        /> <Input
        placeholder="Price"
        onChange={(e) => setTokenId(e.target.value)}
        onBlur={() => {}}
        value={tokenId}
        icon="sell"
      /><HomeButton>
          <HomeButtonBorder />
          <HomeButtonText
            onClick={() =>
              mint({
                token_id: tokenId,
                owner: connectedUser,
                land_type: itemSelected.toLowerCase()
              })}
            
          >
            <svg>
              <use xlinkHref="/icons/sprites.svg#map" />
            </svg>
            {`MINT A NEW LAND`}
          </HomeButtonText>
        </HomeButton>
    </>
  )
}
