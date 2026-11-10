# Mapa dos .DAT exportados do Proteus (Graph > Export Graph Data).
# Coluna 0 = FREQ; depois os ganhos em dB na ordem dos tracos e, em seguida, as fases.
# Cabecalhos reais:
#   PASSA_ALTA.DAT   "FREQ","U1(OP)","U2(OP)","RC","U1 fase","U2 fase","RC"      (U1 = ganho 3, U2 = ganho 30)
#   PASSA_BAIXA.DAT  "FREQ","U1(OP)","U2(OP)","RC","U1 fase","U2 fase","RC"      (U1 = TL082, U2 = LM324)
#   QUINTA_ORDEM.DAT "FREQ","U1(OP)","U2(OP)","U3(OP)","U1 fase","U2 fase","U3 fase"
$colunas = @{
    rc_pa       = @{ arq = 'PASSA_ALTA.DAT';   ganho = 3; fase = 6 }
    item1       = @{ arq = 'PASSA_ALTA.DAT';   ganho = 1; fase = 4 }
    item2       = @{ arq = 'PASSA_ALTA.DAT';   ganho = 2; fase = 5 }
    rc_pb       = @{ arq = 'PASSA_BAIXA.DAT';  ganho = 3; fase = 6 }
    item3_tl082 = @{ arq = 'PASSA_BAIXA.DAT';  ganho = 1; fase = 4 }
    item3_lm324 = @{ arq = 'PASSA_BAIXA.DAT';  ganho = 2; fase = 5 }
    e1          = @{ arq = 'QUINTA_ORDEM.DAT'; ganho = 1; fase = 4 }
    e2          = @{ arq = 'QUINTA_ORDEM.DAT'; ganho = 2; fase = 5 }
    e3          = @{ arq = 'QUINTA_ORDEM.DAT'; ganho = 3; fase = 6 }
}
