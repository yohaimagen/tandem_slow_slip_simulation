function sigmoid(x, alpha)
    return 1 / (1 + math.exp(-alpha * x))
end
function smooth_boxcar(x, start_p, end_p, sse_sn, sn, alpha)
    scale = -sn + sse_sn
    return (sigmoid(x - start_p, alpha) - sigmoid(x - end_p, alpha)) * scale + sn
end



local CASC = {}
CASC.__index = CASC

CASC.amax = 0.025
CASC.rho0 = 2.670
CASC.cs = 3.464
CASC.nu = 0.25
CASC.agl_pr = 1.0
CASC.b = 0.0045 * CASC.agl_pr
CASC.V0 = 1.0e-6
CASC.f0 = 0.6

function CASC.new(params)
    local self = setmetatable({}, CASC)
    self.dip = params.dip * math.pi / 180.0
    self.Vp = params.Vp
    self.l_right = params.right
    self.w = params.w
    self.right = (self.l_right) * math.sin(self.dip)
    self.left = (self.l_right - (self.w + 16)) * math.sin(self.dip)
    self.sse_sn = params.sse_sn
    
    return self
end

function CASC:boundary(x, y, t)
    local Vh = self.Vp * t
    local dist = x + y / math.tan(self.dip)
    if dist > 1 then
        Vh = -Vh / 2.0
    elseif dist < -1 then
        Vh = Vh / 2.0
    end
    return Vh * math.cos(self.dip), -Vh * math.sin(self.dip)
end

function CASC:mu(x, y)
    return self.cs^2 * self.rho0
end

function CASC:lam(x, y)
    return 2 * self.nu * self:mu(x,y) / (1 - 2 * self.nu)
end

function CASC:eta(x, y)
    return self.cs * self.rho0 / 2.0
end

function CASC:L(x, y)
    local d = math.abs(y)
    
    return smooth_boxcar(d, self.left , self.right, 0.00016, 0.013, 2)
end

function CASC:Sinit(x, y)
    return 0.0
end

function CASC:Vinit(x, y)
    return self.Vp
end

function CASC:a(x, y)
    local d = math.abs(y)
    if d < 2.2870286 then
        a = d * -0.0022736925993335887 + 0.004199999999999999
    elseif d < 19.75161063 then
        a = -0.001
    else
        a = d * 0.00018769695003879544 -0.004707317073170733
    end
    return a  + 0.002
end

function CASC:sn_pre(x, y)
    -- positive in compression
    local d = math.abs(y)
    return smooth_boxcar(d, self.left , self.right, self.sse_sn, 50, 2)
    
end

function CASC:tau_pre(x, y)
    local Vi = self:Vinit(x, y)
    local sn = self:sn_pre(x, y)
    local e = math.exp((self.f0 + self.b * math.log(self.V0 / math.abs(Vi))) / self.amax)
    return -(sn * self.amax * math.asinh((Vi / (2.0 * self.V0)) * e) + self:eta(x, y) * Vi)
end



casc_80_sn_1 = CASC.new{dip=10, Vp=3.7e-9, w=80, right=256, sse_sn=1}
casc_80_sn_2 = CASC.new{dip=10, Vp=3.7e-9, w=80, right=256, sse_sn=2}
casc_80_sn_3 = CASC.new{dip=10, Vp=3.7e-9, w=80, right=256, sse_sn=3}
casc_80_sn_5 = CASC.new{dip=10, Vp=3.7e-9, w=80, right=256, sse_sn=5}
casc_80_sn_6 = CASC.new{dip=10, Vp=3.7e-9, w=80, right=256, sse_sn=6}


