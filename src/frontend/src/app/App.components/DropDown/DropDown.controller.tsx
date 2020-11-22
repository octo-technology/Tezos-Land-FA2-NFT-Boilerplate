import * as PropTypes from 'prop-types'
import * as React from 'react'
import { useState } from 'react'

import { DropDownView } from './DropDown.view'

type DropDownProps = {
    icon?: string
    placeholder: string
    name?: string
    value?: string
    onChange: any
    onBlur: any
    inputStatus?: 'success' | 'error'
    type: string
    errorMessage?: string
    items: readonly string[]
    clickOnDropDown:() => void
    clickOnItem: (value: string) => void
    isOpen: boolean
    itemSelected: string
}

export const DropDown = ({  icon,
    placeholder,
    name,
    value,
    onChange,
    onBlur,
    inputStatus,
    type,
    errorMessage, 
    items,
    isOpen,
    itemSelected,
    clickOnItem,
    clickOnDropDown}: DropDownProps) => {

  return (
    <DropDownView
    type={type}
    icon={icon}
    name={name}
    placeholder={placeholder}
    value={value}
    onChange={onChange}
    onBlur={onBlur}
    inputStatus={inputStatus}
    errorMessage={errorMessage}
    isOpen={isOpen}
    items={items}
    itemSelected={itemSelected}
    onClick={clickOnDropDown}
    clickItem={clickOnItem}
    />
  )
}

DropDown.propTypes = {
    icon: PropTypes.string,
    placeholder: PropTypes.string,
    name: PropTypes.string,
    value: PropTypes.string,
    onChange: PropTypes.func.isRequired,
    onBlur: PropTypes.func.isRequired,
    inputStatus: PropTypes.string,
    type: PropTypes.string,
    errorMessage: PropTypes.string,
  }
  
  DropDown.defaultProps = {
    icon: undefined,
    placeholder: undefined,
    name: undefined,
    value: undefined,
    inputStatus: undefined,
    type: 'text',
  }
  