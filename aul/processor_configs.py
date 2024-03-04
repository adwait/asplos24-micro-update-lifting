'''
    Library of processor configurations
'''

from typing import Dict
from aul.processor_config import ProcessorConfig
from aul.sodor_configs import sodor5_itype_config, sodor5_rtype_config, sodor5_iltype_config, sodor5_ilstype_config
from aul.cva6_configs import cva6_wbuffer_config, cva6_tlb_config, cva6_su_config, cva6_lsu_config_full, cva6_lsu_config_hier

CONFIGS : Dict[str, ProcessorConfig] = {
    # sodor5 configs
    'sodor5_itype'  : sodor5_itype_config.sodor5_itype_config
    , 'sodor5_rtype'  : sodor5_rtype_config.sodor5_rtype_config
    , 'sodor5_iltype' : sodor5_iltype_config.sodor5_iltype_config
    , 'sodor5_ilstype': sodor5_ilstype_config.sodor5_ilstype_config
    # cva6 configs
    , 'cva6_wbuffer'  : cva6_wbuffer_config.cva6_wbuffer_config
    , 'cva6_tlb'      : cva6_tlb_config.cva6_tlb_config
    , 'cva6_su'     : cva6_su_config.cva6_su_config
    , 'cva6_lsu'    : cva6_lsu_config_full.cva6_lsu_config
    , 'cva6_lsu_2'  : cva6_lsu_config_hier.cva6_lsu_config
}