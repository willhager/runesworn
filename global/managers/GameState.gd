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
