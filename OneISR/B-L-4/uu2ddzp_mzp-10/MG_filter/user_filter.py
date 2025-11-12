import madgraph.core.drawing as drawing

def remove_diag(diag, model):
    ''' Keep diagrams only with H2 radiation '''

    draw = drawing.FeynmanDiagram(diag, model)
    draw.load_diagram()
    print(draw._debug_load_diagram())

    draw.define_level()

    # remove all 4 point interaction
    #for v in draw.vertexList:
    #    if len(v.lines) > 3:
    #        return True

    for p in draw.lineList: # vertex with only one leg for initial/final state particles
        if abs(p.id) == 9900032:
            if ISR(p):
                return False
            if qqF(p):
                return True
    return True

def ISR(p):
    for leg in p.begin.lines:
        if leg == p:
            continue
        if len(leg.begin.lines) == 1:
            return True
    return False

def muon_decay(p):
    for leg in p.begin.lines:
        if len(leg.end.lines) == 1:
            return False
    for leg in p.end.lines:
        if abs(leg.id) == 13: 
            return True
        else:
            return False
    return True

def qqF(p):
    for leg in p.begin.lines:
        if leg == p:
            continue
        if len(leg.end.lines) == 1:
            return False
    return True
