--- @class Private
local Private = select(2, ...)

Private.Constants = Private.Constants or {}

Private.Constants.Font = {
    Names = {
        ['Fonts\\ARIALN.TTF'] = 'Arial Narrow',
        ['Fonts\\FRIZQT__.TTF'] = 'Friz Quadrata TT'
    },
    Size = {
        MAX = 24,
        MIN = 12,
        STEP = 2
    },
    Styles = {
        [''] = 'None',
        ['OUTLINE'] = 'Outline',
        ['THICKOUTLINE'] = 'Thick Outline'
    }
}
