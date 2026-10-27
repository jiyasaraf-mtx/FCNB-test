import { chunk0 } from './omnidef_chunk0.js';
import { chunk1 } from './omnidef_chunk1.js';
import { chunk2 } from './omnidef_chunk2.js';
import { chunk3 } from './omnidef_chunk3.js';
import { chunk4 } from './omnidef_chunk4.js';
import { chunk5 } from './omnidef_chunk5.js';
import { chunk6 } from './omnidef_chunk6.js';
import { chunk7 } from './omnidef_chunk7.js';
import { chunk8 } from './omnidef_chunk8.js';
import { chunk9 } from './omnidef_chunk9.js';
import { chunk10 } from './omnidef_chunk10.js';


                let def = '';
                def += chunk0;
def += chunk1;
def += chunk2;
def += chunk3;
def += chunk4;
def += chunk5;
def += chunk6;
def += chunk7;
def += chunk8;
def += chunk9;
def += chunk10;


                def = decodeURIComponent(atob(def));
                export const OMNIDEF = JSON.parse(def);