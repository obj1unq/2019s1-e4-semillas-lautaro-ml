object parcelaEcologica  {}
object parcelaIndustrial {}

object inta {
	var property parcelas = []
	
	method agregar(unaParcela) {
		parcelas.add(unaParcela)
	}
	
	method quitar(unaParcela) {
		parcelas.remove(unaParcela)
	}
	
	method promedioDePlantas() {
		return parcelas.sum( { parcela => parcela.plantas().size() } ) / parcelas.size()
	}
	
	method parcelaMasAutosustentable() {
		var ret = parcelas.filter( { parcela => parcela.plantas().size() >= 4 } )
		return ret.max( { parcela => 
			parcela.plantas().count( { planta => planta.seAsociaBienA(parcela) } ) / parcela.plantas().size()
		} )
	}
}

class Parcela {
	const property tipo
	const property largo
	const property ancho
	const property horasDeSol
	var   property plantas = []
	
	method agregar(unaPlanta) {
		if (plantas.size() >= self.capacidad() 
		   	||
	 	   	unaPlanta.horasDeSol() <= horasDeSol-2
		   ) { self.error("No se puede plantar una planta aqui") } 
		else { plantas.add(unaPlanta) }
	}
	
	method quitar(unaPlanta) {
		plantas.remove(unaPlanta)
	}
	
	method superficie() {
		return largo*ancho
	}
	
	method capacidad() {
		return if (ancho > largo) { self.superficie()/5 } else { self.superficie()/3 + largo }
	}
	
	method hayProblemas() {
		return plantas.any( { planta => planta.horasDeSol() < horasDeSol } )
	}
	
	
}

class Planta {
	var property anoDeObtencion
	var property altura
	
	method esFuerte() {
		return (self.horasDeSol() >= 10)
	}
	
	method horasDeSol() { return null }
	
	method seAsociaBienA(unaParcela) {
		return if (unaParcela.tipo() == parcelaEcologica) {
			(not unaParcela.hayProblemas()) && self.esIdeal(unaParcela)
		} else {
			unaParcela.plantas().size() <= 2 && self.esFuerte()
		}
	}
	
	method esIdeal(unaParcela) { return null }
}

class Menta inherits Planta {
	
	override method horasDeSol() {
		return 6
	}
	
	method daSemillas() {
		return ((altura >= 0.4) || self.esFuerte())
	}
	
	method espacioQueOcupa() {
		return altura*3
	}
	
	override method esIdeal(unaParcela) {
		return unaParcela.superficie() > 6
	}

}

class HierbaBuena inherits Menta {
	override method espacioQueOcupa() {
		return altura*6
	}
}

class Soja inherits Planta {
	
    override method horasDeSol() {
		return if (altura < 0.5) { 6 } else { if (altura >= 0.5 && altura < 1) { 7 } else { 9 } }
	}
	
	method daSemillas() {
		return ((altura > 1 && anoDeObtencion > 2007) || self.esFuerte())
	}
	
	method espacioQueOcupa() {
		return altura/2
	}
	
	override method esIdeal(unaParcela) {
		return unaParcela.horasDeSol() == self.horasDeSol()
	}
}

class SojaTransgenica inherits Soja {
	
	override method daSemillas() {
		return false
	}
	
	override method esIdeal(unaParcela) {
		return unaParcela.capacidad() == 1
	}
}

class Quinoa inherits Planta{
	
	const property horasDeSol
	
	override method horasDeSol() {
		return horasDeSol
	}
	
	method daSemillas() {
		return ((anoDeObtencion < 2005 || self.esFuerte()))
	}
	
	method espacioQueOcupa() {
		return 0.5
	}
	
	override method esIdeal(unaParcela) {
		return unaParcela.plantas().all( { planta => planta.altura() <= 1.5 } )
	}
}