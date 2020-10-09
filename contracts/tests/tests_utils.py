
administrator = "tz1ibMpWS6n6MJn73nQHtK5f4ogyYC1z9T9z"
alice = "tz1L738ifd66ah69PrmKAZzckvvHnbcSeqjf"
bob = "tz1LFuHW4Z9zsCwg1cgGTKU12WZAs27ZD14v"
frank = "tz1Qd971cetwNr5f4oKp9xno6jBvghZHRsDr"
pascal = "tz1TgK3oaBaqcCHankT97AUNMjcs87Tfj5vb"
jacob = "tz1VphG4Lgp39MfQ9rTUnsm7BBWyXeXnJSMZ"
lucina = "tz1ZAZo1xW4Veq5t7YqWy2SMbLdskmeBmzqs"
mark = "tz1ccWCuJqMxG4hoa1g5SKhgdTwXoJBM8kpc"
jean = "tz1hQzKQpprB5JhNxZZRowEDRBoieHRAL84b"
boby = "tz1hTic2GpaNumpTtYwqyPSBd9KcWifRMuEN"
bartholome = "tz1hv9CrgtaxiCayc567KUvCyWDQRF9sVNuf"
lucas = "tz1iWMsg4UNSSQNKYsiH5s2maUZ9xBwymXxR"


def get_storage(self, funds_by_owner=None, buyers=None, lands=None, admin=administrator, height=10, width=10,
                to_sell=None, ledger=None, operators=None):
    if operators is None:
        operators = {}
    if ledger is None:
        ledger = {}
    if to_sell is None:
        to_sell = {}
    if lands is None:
        lands = {}
    if buyers is None:
        buyers = {}
    if funds_by_owner is None:
        funds_by_owner = {}
    return {"market": {"fundsByOwner": funds_by_owner,
                       "buyers": buyers,
                       "lands": lands,
                       "admin": admin,
                       "height": height, "width": width,
                       "to_sell": to_sell},
            "ledger": ledger,
            "operators": operators,
            "metadata": {"token_defs": [{"from_": 1, "to_": 100}],
                         "last_used_id": 1,
                         "metadata": {(1, 100): {"token_id": 1,
                                                 "symbol": "TLD",
                                                 "name": "TezosLand",
                                                 "decimals": 0,
                                                 "extras": {}
                                                 }
                                      }}
            }