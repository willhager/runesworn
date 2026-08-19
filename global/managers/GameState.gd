extends Node

var health : int
var numSelected : int = 0
var selectedArry : Array[bool]
var selectedAttackDice : int = 0
var maxDieNum : int = Global.maxSelectableDice

var player_damage : int
var player_heal : int
var player_shield : int
var player_piercing : int
var player_freeze : int
var player_explosive : int

var pDiceRolls : Array[Dictionary]
var pDiceRolls_copy : Array[Dictionary]

var enemyHealth : int
var maxHealth : int
var enemy_damage : int
var enemy_heal : int
var enemy_shield : int
var enemy_piercing : int
var enemy_poison_counter : int
var EDice : Array[Dictionary] # Array of dice themselves, should remain static aside from freeze
var eDiceRolls : Array[Dictionary] # Array of dice rolls, should contain individual faces as values


func copy_pDiceRolls_deep() :
	for i in range(0, pDiceRolls.size()) :
		if selectedArry[i] :
			pDiceRolls_copy.append(pDiceRolls[i].duplicate())

func clear_pDiceRolls_deep_copy() :
	pDiceRolls_copy = []
