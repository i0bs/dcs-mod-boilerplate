dofile(LockOn_Options.common_script_path.."elements_defs.lua")

_MASK_ 	 			= MakeMaterial(nil,{0,125,125,125})
_FNT_				= MakeFont({used_DXUnicodeFontData = "font_dejavu_lgc_sans_22"},{125,125,0,255})
_FNT_GREEN_			= MakeFont({used_DXUnicodeFontData = "font_dejavu_lgc_sans_22"},{0  ,255,0,255})
_FNT_RED_			= MakeFont({used_DXUnicodeFontData = "font_dejavu_lgc_sans_22"},{255,0,  0,255})

_T_RED_				= MakeMaterial("arcade.tga",{255,0,0,255})
_T_GREEN_			= MakeMaterial("arcade.tga",{0,255,0,255})
_T_BLUE_			= MakeMaterial("arcade.tga",{0,0,255,255})
_T_YELLOW_			= MakeMaterial("arcade.tga",{255,255,0,255})
_T_BACK_			= MakeMaterial("radar.tga",{255, 255, 255, 120})
_T_GREY_			= MakeMaterial("arcade.tga",{120,120,120,255})
_T_PURPLE_			= MakeMaterial("arcade.tga",{255,0,255,255})
_T_GREEN_TRANSP_	= MakeMaterial("arcade.tga",{0,255,0,120})
_T_RED_TRANSP_		= MakeMaterial("arcade.tga",{255,0,0,120})
_T_YELLOW_TRANSP_	= MakeMaterial("arcade.tga",{255,255,0,120})

local fw = 1.5 *0.001
local fh = 1.5 *0.0035

_FONT_SIZE_			= {fh,fw,0,0}
_FONT_SIZE_2_		= {0.5 * fh,0.5 *fw,0,0}

gettext = require("i_18n")

_ = gettext.translate

SetCustomScale(1.0)

function AddElement(object)
	object.screenspace = ScreenType.SCREENSPACE_TRUE
    object.use_mipfilter = true
    Add(object)
end

hsd_size        = 0.3
hsd_size_border = (hsd_size)*( 1 + 35 /(256 - 35))
hud_symbol_size = 0.03

hsd_symbol_size = 0.01 * 1.5

hsd_coeff       = hsd_symbol_size / hud_symbol_size


curr_target_size_y_px = 0.5 * (79 - 24) / 256
curr_target_size_x_px = 0.5 * (111 -70) / 256

curr_target_size_y    = 1.5 * hud_symbol_size
curr_target_size_x    = (curr_target_size_x_px / curr_target_size_y_px) * curr_target_size_y
hud_symbol_size_px    = curr_target_size_y_px / 1.5 

trg_size_x_px = 0.5 * 30/256
trg_size_y_px = 0.5 * 37.5/256

trg_size_x = ( trg_size_x_px / hud_symbol_size_px) * hud_symbol_size
trg_size_y = ( trg_size_y_px / hud_symbol_size_px) * hud_symbol_size



tex_scale       = curr_target_size_y_px / curr_target_size_y

aspect   = LockOn_Options.screen.aspect

local   sight_size              = ((0.5*(79 - 51)/256) / hud_symbol_size_px) * hud_symbol_size
local   sight_vertices     	    = {{-sight_size,-sight_size}, 
                                   {-sight_size, sight_size},
                                   { sight_size, sight_size},
                                   { sight_size,-sight_size}}


function set_clear_level(level,controllers)
local  clear_level					= CreateElement "ceMeshPoly"
       clear_level.primitivetype    = "triangles"
       clear_level.vertices			= {{-aspect,-1}, 
                                       {-aspect, 1},
                                       { aspect, 1},
                                       { aspect,-1}}
       clear_level.indices			= default_box_indices
       clear_level.material			= _MASK_
       clear_level.h_clip_relation  = h_clip_relations.REWRITE_LEVEL
       clear_level.level		  	= DEFAULT_LEVEL + level
       if controllers then
       clear_level.controllers      = controllers
       end
       clear_level.isvisible        = false
       AddElement(clear_level)
       return                       clear_level
end

function add_hud()
local  clear_level = set_clear_level(1)
       add_current_sight_hud(clear_level)


local     target_hud             = CreateElement "ceSimple"
          if LockOn_Options.flight.radio_assist then  
          target_hud.controllers      = {{"reset_buffer",0},{"draw_targets",0},{"draw_mlws_contacts",0},{"apply_buffer",0}}
          else
          target_hud.controllers      = {{"reset_buffer",0},{"draw_targets",0},{"apply_buffer",0}}
          end
          AddElement(target_hud) 
		  

local most_left = -5 * sight_size      

local full_sz 	= 10 * (2*sight_size) + (10 - 1) * (sight_size)

most_left = -0.5 * full_sz + sight_size


local   selector_size              = ((0.5*(257 - 223)/256) / hud_symbol_size_px) * hud_symbol_size
local   selector_vertices       = {{-selector_size,-selector_size}, 
                                   {-selector_size, selector_size},
                                   { selector_size, selector_size},
                                   { selector_size,-selector_size}}

local   selector                    = CreateElement "ceTexPoly"
        selector.vertices			= selector_vertices
        selector.indices			= default_box_indices
        selector.material			= _T_RED_
        selector.tex_params		    = {101/512,257/512,tex_scale,tex_scale}
        selector.additive_alpha     = true
        selector.parent_element     = target_hud.name
        selector.controllers        = {{"draw_selector_point"}}
        AddElement(selector)
       
return target_hud
end

function add_hsd()

local   clear_level                 = set_clear_level(1,{{"show_radar"}})


local   internal_part               = CreateElement "ceMeshPoly"
        internal_part.name          = "radar_internal_part"
        internal_part.primitivetype = "triangles"
        internal_part.material      = _MASK_
        internal_part.init_pos      = {aspect - hsd_size_border, 1 - hsd_size_border,0}
        set_circle(internal_part,0.95*hsd_size_border)
        internal_part.parent_element   = clear_level.name
        internal_part.isvisible        = false
        internal_part.h_clip_relation  = h_clip_relations.INCREASE_LEVEL
        AddElement(internal_part)
     
local   target_hsd       			= CreateElement "ceTexPoly"
        target_hsd.name				= _T_BACK_
        target_hsd.material			= _T_BACK_
        set_circle(target_hsd,hsd_size_border)
        target_hsd.tex_params		= {0.5,0.5,0.5/hsd_size_border,0.5/hsd_size_border}
        target_hsd.parent_element    = internal_part.name
        if LockOn_Options.flight.radio_assist then        target_hsd.controllers      = {{"reset_buffer",1},{"draw_targets",1},{"draw_airfields",1},{"draw_mlws_contacts",1},{"apply_buffer",1}}
        else                                              target_hsd.controllers      = {{"reset_buffer",1},{"draw_targets",1},{"draw_airfields",1},{"apply_buffer",1}}        end
        target_hsd.h_clip_relation  = h_clip_relations.INCREASE_LEVEL
        AddElement(target_hsd)

local   tick      = {}
local   line_width                      = 2 * hsd_coeff *(0.5*(4.5/256)/ tex_scale)
local   sz                              = 1.463 * hsd_coeff *(0.5*(236/256)/ tex_scale)

for i = 1, 8 do
local angle = 45 * (i - 1)
    if angle ~= 0 and angle ~= 180  then
 
        tick[i]             = CreateElement "ceTexPoly"
        tick[i].vertices    = {{0    , -line_width},
                               {0    ,  line_width},
                               {sz   ,  line_width},
                               {sz   , -line_width}}
        tick[i].indices		= default_box_indices
        tick[i].init_pos    = {hsd_size_border*math.sin(math.rad(angle)),hsd_size_border*math.cos(math.rad(angle))}
        tick[i].init_rot    = {-(90 + angle),0,0}     
        tick[i].material	= _T_YELLOW_
        tick[i].tex_params	   = {128/512,176.5/512,(tex_scale/hsd_coeff),(tex_scale/hsd_coeff)}
        tick[i].parent_element = target_hsd.name
        tick[i].additive_alpha = true
        AddElement(tick[i])
   end
end

--add_pitch_bank_scale_hsd(target_hsd)
  
local   hsd_2 = Copy(target_hsd)
        set_circle(hsd_2,0.5*hsd_size_border)
        hsd_2.init_pos         = {0,-0.75 * hsd_size_border,0}
        hsd_2.tex_params       = {0.5,0.5, 2 * 0.5/hsd_size_border,2 * 0.5/hsd_size_border}
        hsd_2.controllers      = {}
        hsd_2.h_clip_relation  = h_clip_relations.COMPARE
        hsd_2.level	           = DEFAULT_LEVEL + 1
        hsd_2.parent_element   = target_hsd.name
        AddElement(hsd_2)
--[[        
local   hsd_3                  = Copy(hsd_2)
        hsd_3.init_pos         = {-hsd_size_border,0,0}
        AddElement(hsd_3)   
        
local   vy                = CreateElement "ceTexPoly"
        vy.vertices       = {{0    , -line_width},
                             {0    ,  line_width},
                             {sz   ,  line_width},
                             {sz   , -line_width}}
        vy.indices		  = default_box_indices
        vy.controllers    = {{"vy_scale",-math.rad(75)/30}}
        vy.material	      = _T_YELLOW_
        vy.init_rot       = {180,0,0}
        vy.tex_params	  = {128/512,176.5/512,(tex_scale/hsd_coeff),(tex_scale/hsd_coeff)/1}
        vy.parent_element = hsd_3.name
        vy.additive_alpha = true
        AddElement(vy)
        
-]]
        add_vy_block(target_hsd)

local   txt_scale                 = CreateElement "ceStringPoly"
        txt_scale.name            = "txt_IAS"
        txt_scale.material        = _FNT_
        txt_scale.init_pos		  = {0,-0.385 * hsd_size}
        txt_scale.alignment       = "CenterCenter"
        txt_scale.stringdefs      = _FONT_SIZE_
        txt_scale.formats         = {"%02.f"}
        txt_scale.controllers     = {{"txt_scale",0,0.001}}
        txt_scale.parent_element  = hsd_2.name
        txt_scale.additive_alpha  = true
        AddElement(txt_scale)
-------------------------height block---------------------------------------------------------------------------------------------------------------
        add_baro_altitude_block(target_hsd)
        add_radar_altitude_block(target_hsd)
        
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------        
        return  target_hsd        
end

function add_circle_scale(parent,material,intitial_rot,size,controllers,additive)

local   mask                 = CreateElement "ceMeshPoly"
        mask.primitivetype   = "triangles"
        mask.material        = _MASK_
        if parent then 
        mask.parent_element  = parent.name
        end
        mask.isvisible       = false
        set_circle(mask,hsd_size_border,0.95*hsd_size_border,size)
        mask.h_clip_relation = h_clip_relations.INCREASE_IF_LEVEL
        mask.level           = DEFAULT_LEVEL + 2
        AddElement(mask)
        
local   scale                 = CreateElement "ceTexPoly" --"ceMeshPoly"
        scale.primitivetype   = "triangles"
        scale.material        = material
        scale.parent_element  = mask.name
        set_circle(scale,hsd_size_border,0.95*hsd_size_border,size)
        if additive == nil then
        scale.additive_alpha  = false
        else 
        scale.additive_alpha  = additive
        end
        scale.init_rot        = {intitial_rot,0,0}
        scale.controllers     = controllers
        scale.h_clip_relation = h_clip_relations.COMPARE
        scale.level           = DEFAULT_LEVEL + 3
        
        local   scale_tex     = (255 / 512)/(0.99*hsd_size_border)
        
        scale.tex_params      = {0.5,0.5,scale_tex,scale_tex}
        AddElement(scale)
        
local   mask_return                 = Copy(mask)
        mask_return.h_clip_relation = h_clip_relations.DECREASE_IF_LEVEL
        mask_return.level           = DEFAULT_LEVEL + 3
        mask_return.parent_element  = mask.name
        mask_return.isvisible       = false
        AddElement(mask_return)
        
        return mask
end


function add_baro_altitude_block(parent)

local   base             = CreateElement "ceSimple"
        base.parent_element = parent.name
        base.controllers = {{"switch_altitude_scale_radar",0,900}}
        AddElement(base)

       
      add_circle_scale(base,"ARCADE_YELLOW",135,-135,{{"baro_altitude_rotate" ,-math.rad(135)/6000}}) 
      add_circle_scale(base,"ARCADE",135,-135,{{"surface_height_rotate",-math.rad(135)/6000}},false)
end

function add_radar_altitude_block(parent)
local   radar             =  add_circle_scale(parent,"ARCADE_YELLOW",135,-135,{{"radar_altitude_rotate",-math.rad(135)/900}})
        radar.controllers = {{"switch_altitude_scale_radar",1,900}}
end

function add_vy_block(parent)

    local vy_1 = add_circle_scale(parent,"ARCADE_YELLOW",-90,90,{{"vy_scale",math.rad(45)/30}})
    local vy_2 = add_circle_scale(parent,"ARCADE_YELLOW",90,90,{{"vy_scale",math.rad(45)/30}})
          vy_2.init_rot = {-90,0,0}

end

function add_current_sight_hud(parent)

local   sight_size              = ((0.5*(79 - 51)/256) / hud_symbol_size_px) * hud_symbol_size


local   sight_clear				   = CreateElement "ceTexPoly"
        sight_clear.primitivetype  = "triangles"
        sight_clear.vertices	   = {{-sight_size,-sight_size}, 
                                      {-sight_size, sight_size},
                                      { sight_size, sight_size},
                                      { sight_size,-sight_size}}
        sight_clear.indices		   = default_box_indices
        sight_clear.material	   = _MASK_
        sight_clear.h_clip_relation= h_clip_relations.INCREASE_LEVEL
        sight_clear.isvisible      = false
        sight_clear.controllers    =  {{"draw_sight_hud"}}
        if parent then
        sight_clear.parent_element = parent.name
        end
        AddElement(sight_clear)

local   sight					= CreateElement "ceTexPoly"
        sight.vertices			= sight_clear.vertices
        sight.indices			= sight_clear.indices
        sight.material			= _T_RED_
        sight.tex_params		= {0.5, 0.5, tex_scale, tex_scale}
        sight.parent_element    = sight_clear.name
        sight.additive_alpha    = true
        AddElement(sight)
		
		
local   sight_standby_gun_clear				   = CreateElement "ceTexPoly"
        sight_standby_gun_clear.primitivetype  = "triangles"
        sight_standby_gun_clear.vertices	   = {{-sight_size,-sight_size}, 
												  {-sight_size, sight_size},
												  { sight_size, sight_size},
												  { sight_size,-sight_size}}
        sight_standby_gun_clear.indices		   = default_box_indices
        sight_standby_gun_clear.material	   = _MASK_
        sight_standby_gun_clear.h_clip_relation= h_clip_relations.INCREASE_LEVEL
        sight_standby_gun_clear.isvisible      = false
        sight_standby_gun_clear.controllers    =  {{"draw_sight_hud",1.0}}
        if parent then
        sight_standby_gun_clear.parent_element = parent.name
        end
        AddElement(sight_standby_gun_clear)

local   sight_standby_gun					= CreateElement "ceTexPoly"
        sight_standby_gun.vertices			= sight_standby_gun_clear.vertices
        sight_standby_gun.indices			= sight_standby_gun_clear.indices
        sight_standby_gun.material			= _T_RED_
        sight_standby_gun.tex_params		= {100/512, 363.5/512, tex_scale, tex_scale}
        sight_standby_gun.parent_element    = sight_standby_gun_clear.name
        sight_standby_gun.additive_alpha    = true
        AddElement(sight_standby_gun)

local   forestall_base                = CreateElement "ceSimple"
        forestall_base.controllers    = {{"draw_forestall_hud"}}
        if parent then
        forestall_base.parent_element = parent.name
        end
        AddElement(forestall_base)
 
       
local   forestall_size              = ((0.5*(79 - 63)/256) / hud_symbol_size_px) * hud_symbol_size

local   forestall = {}
for     i=1,2 do
        forestall[i]					= CreateElement "ceTexPoly"
        forestall[i].vertices			= {{-forestall_size,-forestall_size}, 
                                           {-forestall_size, forestall_size},
                                           { forestall_size, forestall_size},
                                           { forestall_size,-forestall_size}}
        forestall[i].indices			= default_box_indices
        forestall[i].tex_params	    	= {394/512,0.5, tex_scale, tex_scale}  
        if i == 1 then
        forestall[i].material			= _T_RED_
        forestall[i].controllers        = {{"draw_fire_permission",1},{"draw_iff_color"}}
        else
        forestall[i].material			= _T_GREY_
        forestall[i].controllers        = {{"draw_fire_permission",0}}
        end
        forestall[i].parent_element     = forestall_base.name    
        forestall[i].additive_alpha     = true
        AddElement(forestall[i])
end
end


function  add_pitch_bank_scale_hsd(parent)


local   size_factor      =  0.5
local   scale_size_x     =  0.19  *size_factor
local   scale_size_y_min =  0.013 *size_factor
local   scale_size_y_max =  2.1   *size_factor
local   scale_tex        =  0.35 / size_factor
local   pitch_K          =-(1.25 * scale_size_x) / math.rad(10) 
local   pitch_bank_scale = {}

local   base_obj         = CreateElement "ceSimple" 
        base_obj.parent_element = parent.name
        base_obj.controllers = {{"pitch_scale", pitch_K}}--,{"bank_scale"}}
        AddElement(base_obj)
local   use_cone = true
for i = 1,2 do
    pitch_bank_scale[i]            = CreateElement "ceTexPoly" 
    pitch_bank_scale[i].indices    = default_box_indices
    pitch_bank_scale[i].material   = "ARCADE_3"
    if i == 1 then
        if use_cone then 
        pitch_bank_scale[i].vertices = {{-0.2*scale_size_x, -scale_size_y_min}, 
                                        {    -scale_size_x,  scale_size_y_max},
                                        {     scale_size_x,  scale_size_y_max},
                                        { 0.2*scale_size_x, -scale_size_y_min}}
        pitch_bank_scale[i].tex_params =  {0.07281, 0.74169,scale_tex,scale_tex}
      else
        pitch_bank_scale[i].vertices = {{-scale_size_x, -scale_size_y_min}, 
                                        {-scale_size_x,  scale_size_y_max},
                                        { scale_size_x,  scale_size_y_max},
                                        { scale_size_x, -scale_size_y_min}}
        pitch_bank_scale[i].tex_params =  {0.07281, 0.74169,scale_tex,scale_tex}
        end                      
    else
        if use_cone then
        pitch_bank_scale[i].vertices = {{-0.2*scale_size_x,  scale_size_y_min}, 
                                        {    -scale_size_x, -scale_size_y_max},
                                        {     scale_size_x, -scale_size_y_max},
                                        { 0.2*scale_size_x,  scale_size_y_min}}
        pitch_bank_scale[i].tex_params = {0.20736, 0.01661,scale_tex,scale_tex}
        else
        pitch_bank_scale[i].vertices = {{-scale_size_x,  scale_size_y_min}, 
                                        {-scale_size_x, -scale_size_y_max},
                                        { scale_size_x, -scale_size_y_max},
                                        { scale_size_x,  scale_size_y_min}}
        pitch_bank_scale[i].tex_params = {0.20736, 0.01661,scale_tex,scale_tex}
        end
    end
    pitch_bank_scale[i].parent_element = base_obj.name
    pitch_bank_scale[i].h_clip_relation = h_clip_relations.COMPARE
    pitch_bank_scale[i].level		  	= DEFAULT_LEVEL + 3
    pitch_bank_scale[i].additive_alpha  = true
    AddElement(pitch_bank_scale[i])
end


local   bird_size_x     =  0.16 *size_factor
local   bird_size_y_min = -0.074*size_factor
local   bird_size_y_max =  0.01 *size_factor

local bird_mark            = CreateElement "ceTexPoly"
      bird_mark.name       = "bird_mark"
      bird_mark.vertices   = {{-bird_size_x,bird_size_y_min},
                              {-bird_size_x,bird_size_y_max},
                              { bird_size_x,bird_size_y_max},
                              { bird_size_x,bird_size_y_min}}
      bird_mark.indices    = default_box_indices
      bird_mark.material   = "ARCADE_3"
      bird_mark.tex_params = {0.39978, 0.00941,scale_tex,scale_tex}
      bird_mark.controllers = {{"bank_scale",-1}}
      bird_mark.parent_element = parent.name
      bird_mark.additive_alpha  = true
      AddElement(bird_mark)
end




