/**
 *
 * Descripcion: Implementacion de funciones de tiempo
 *
 * Fichero: tiempos.c
 * Autor: Carlos Aguirre Maeso
 * Version: 1.0
 * Fecha: 16-09-2017
 *
 */

#include "tiempos.h"
#include "ordenacion.h"
#include "permutaciones.h"
#include <time.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <limits.h>

/***************************************************/
/* Funcion: tiempo_medio_ordenacion Fecha:         */
/*                                                 */
/* Vuestra documentacion (formato igual            */
/* que en el primer apartado):                     */
/***************************************************/
short tiempo_medio_ordenacion(pfunc_ordena metodo, int n_perms,int N, PTIEMPO ptiempo){
  int ** perms=genera_permutaciones(n_perms,N);
  clock_t t_ini, t_fin;
  int i,OB,min,max;
  double count=0;
  
  if(perms == NULL)
    return ERR;
    
  min=INT_MAX;
  max=0;
  t_ini=clock();
  
  for(i=0 ; i<n_perms ; i++){
    OB=metodo(perms[i],0,N-1);
    
    if(OB < min)
      min = OB;
    if(OB > max)
      max = OB;
    count+=OB;
  }
  
  t_fin=clock();
  ptiempo->N = N;
  ptiempo->n_elems = n_perms;
  ptiempo->tiempo = ((double)(t_fin - t_ini)/n_perms)/CLOCKS_PER_SEC; 
  ptiempo->medio_ob = count/n_perms;
  ptiempo->min_ob = min;
  ptiempo->max_ob = max;
  
  for(i = 0; i< n_perms; i++){
    free(perms[i]);
  }
  
  free(perms);
  
  return OK;
}

/***************************************************/
/* Funcion: genera_tiempos_ordenacion Fecha:       */
/*                                                 */
/* Vuestra documentacion                           */
/***************************************************/
short genera_tiempos_ordenacion(pfunc_ordena metodo, char* fichero, int num_min, int num_max, int incr, int n_perms){
  int j,i=num_min,num=0;
  PTIEMPO tiempo=NULL;
  
  if(fichero == NULL)
    return ERR;
    
  num = ((num_max-num_min)/incr) + 1;
  tiempo=(PTIEMPO)malloc(num*sizeof(TIEMPO));
  
  for(j = 0 ; j < num ; j++){
    tiempo_medio_ordenacion(metodo,n_perms,i,&tiempo[j]);
    i+=incr;
  }
  
  guarda_tabla_tiempos(fichero,tiempo,num);
  free(tiempo);
  
  return OK;
}

/***************************************************/
/* Funcion: guarda_tabla_tiempos Fecha:            */
/*                                                 */
/* Vuestra documentacion (formato igual            */
/* que en el primer apartado):                     */
/***************************************************/
short guarda_tabla_tiempos(char* fichero, PTIEMPO tiempo, int n_tiempos){
  int i;
  FILE *pf=NULL;
  
  if(fichero == NULL)
    return ERR;
    
  pf = fopen(fichero,"w");
  
  if(pf == NULL)
    return ERR;
    
  for(i = 0 ; i < n_tiempos ; i++){
    fprintf(pf,"%d %f %f %d %d\n",tiempo[i].N,tiempo[i].tiempo,tiempo[i].medio_ob,tiempo[i].max_ob,tiempo[i].min_ob);
  }
  
  fclose(pf);
  
  return OK;
}

/***************************************************/
/* Funcion: tiempo_medio_busqueda Fecha:         */
/*                                                 */
/* Vuestra documentacion (formato igual            */
/* que en el primer apartado):                     */
/***************************************************/
short tiempo_medio_busqueda(pfunc_busqueda metodo, pfunc_generador_claves generador,int orden,int N, int n_veces, PTIEMPO ptiempo){
  
  clock_t t_ini, t_fin;
  int i, j, count = 0, OB, min = INT_MAX, max = 0, pos;
  int* perm;
  int ** table;
  PDICC dicc;
  
  OB = 0;
  
  if(ptiempo == NULL)
    return ERR;
  
  table = (int**) malloc ((n_veces)*sizeof(int*));
  
  dicc = ini_diccionario(N, orden);
  perm = genera_perm(N);
  
  OB += insercion_masiva_diccionario(dicc, perm, N);
  
  for(i = 0; i < n_veces; i++){
    table[i] = (int*)malloc(N*sizeof(int));
    generador(table[i], N, N);
  }
  
  t_ini=clock();
  
  for (i = 0; i < n_veces ; i++){
    for(j = 0 ; j <  N ; j++){
      OB = metodo(dicc->tabla, 0, N-1, table[i][j], &pos);
      
      if(OB < min)
        min = OB;
      if(OB > max)
        max = OB;
      
      count+=OB;
    }
  }
  t_fin=clock();
  
  ptiempo->N = N;
  ptiempo->n_elems = n_veces*N;
  ptiempo->tiempo = ((double)(t_fin - t_ini)/(n_veces * N))/CLOCKS_PER_SEC;
  ptiempo->medio_ob = (count*1.0)/(n_veces*N);
  ptiempo->min_ob = min;
  ptiempo->max_ob = max;
  
  free(perm);
  for (i = 0; i < n_veces; i++)
    free(table[i]);
  free(table);
    
  libera_diccionario(dicc);
  
  return OK;
}

/***************************************************/
/* Funcion: genera_tiempos_busqueda Fecha:         */
/*                                                 */
/* Vuestra documentacion (formato igual            */
/* que en el primer apartado):                     */
/***************************************************/
short genera_tiempos_busqueda(pfunc_busqueda metodo, pfunc_generador_claves generador, int orden, char* fichero, int num_min, int num_max, int incr, int n_veces){
  int i = num_min, num, j;
  PTIEMPO tiempo;
    
  num = ((num_max-num_min)/incr) + 1;
  tiempo=(PTIEMPO)malloc(num*sizeof(TIEMPO));
  
  for(j=0 ; j < num ; j++){
    tiempo_medio_busqueda(metodo, generador, orden, i,  n_veces, &tiempo[j]);
    i += incr;
  }
  
  guarda_tabla_tiempos(fichero,tiempo,num);
  free(tiempo);
  
  return OK;
}




