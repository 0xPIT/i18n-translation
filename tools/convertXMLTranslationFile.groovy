import groovy.json.JsonBuilder
import groovy.json.JsonOutput

def xml = new XmlSlurper().parse('/Users/pit/Development/hg/ofbiz/hot-deploy/ecommerce/config/EcommerceUiLabels.xml')

def result = [:]

xml.property.each {
	def key = it.@key
	def values = it.children()
	def mapChild = values.each {
		def v = it;
		def lang = it.'@xml:lang'.text()

		if (lang in ['de', 'en']) {
			if (!result[lang]) {
				result[lang] = []
			}
			
			result[lang] << [
           		key: "" + key,
           		val: "" + v.text()  
	        ]
		}
	}
}

def json = new JsonBuilder()
json result

println JsonOutput.prettyPrint(json.toString())

new File("translation.json").write(JsonOutput.prettyPrint(json.toString()))
