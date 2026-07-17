from pydantic import BaseModel, Field

class SegmentationInput(BaseModel):
    recency: int = Field(..., description="Nombre de jours depuis le dernier achat du client.", example=30)
    frequency: int = Field(..., description="Nombre total de commandes du client.", example=5)
    monetary: float = Field(..., description="Montant total depense par le client.", example=500.0)


class ReviewClassificationInput(BaseModel):
    order_status: str = Field(..., description="Statut de la commande.", example="delivered")
    delay_days: float = Field(..., description="Nombre de jours de retard par rapport a la date estimee.", example=-8.0)
    delivery_days: float = Field(..., description="Nombre total de jours entre achat et livraison.", example=8.0)
    n_items: float = Field(..., description="Nombre d articles dans la commande.", example=1.0)
    customer_state: str = Field(..., description="Etat du client.", example="SP")
    main_category: str = Field(..., description="Categorie principale du produit achete.", example="housewares")
    purchase_month: int = Field(..., description="Mois d achat de la commande.", example=10)
    total_freight: float = Field(..., description="Montant total des frais de livraison.", example=8.72)

class DemandInput(BaseModel):
    order_status: str = Field(..., description="Statut de la commande.", example="delivered")
    customer_state: str = Field(..., description="Etat du client.", example="SP")
    delivery_days: float = Field(..., description="Nombre de jours entre achat et livraison.", example=8.0)
    delay_days: float = Field(..., description="Nombre de jours de retard ou d avance.", example=-8.0)
    purchase_month: int = Field(..., description="Mois d achat.", example=10)
    purchase_dow: int = Field(..., description="Jour de la semaine d achat (0=lundi, 6=dimanche).", example=0)
    total_price: float = Field(..., description="Prix total de la commande.", example=29.99)
    total_freight: float = Field(..., description="Frais de livraison totaux.", example=8.72)
    total_weight: float = Field(..., description="Poids total des articles de la commande.", example=500.0)
    main_category: str = Field(..., description="Categorie principale du produit.", example="housewares")
    payment_value: float = Field(..., description="Montant total paye.", example=38.71)
    max_installments: float = Field(..., description="Nombre maximal de mensualites.", example=1.0)
    payment_type: str = Field(..., description="Type de paiement principal.", example="voucher")


class WeeklyDemandInput(BaseModel):
    recent_weekly_n_items: list[float] = Field(
        ...,
        description="Historique recent de la demande hebdomadaire (n_items), du plus ancien au plus recent.",
        example=[1720.0, 1685.0, 1810.0, 1760.0, 1640.0, 1900.0, 1950.0, 1780.0, 1840.0, 1710.0, 1630.0, 1880.0, 1920.0, 1800.0],
    )
    horizon_days: int = Field(
        7,
        ge=7,
        le=14,
        description="Horizon de prevision en jours (entre 7 et 14).",
        example=14,
    )


class PriceInput(BaseModel):
    order_item_id: int = Field(..., description="Identifiant de la ligne produit dans la commande.", example=1)
    freight_value: float = Field(..., description="Montant des frais de livraison pour la ligne produit.", example=8.72)
    order_status: str = Field(..., description="Statut de la commande.", example="delivered")
    product_category_name: str = Field(..., description="Categorie du produit.", example="housewares")
    product_name_lenght: float = Field(..., description="Longueur du nom du produit.", example=40.0)
    product_description_lenght: float = Field(..., description="Longueur de la description du produit.", example=268.0)
    product_photos_qty: float = Field(..., description="Nombre de photos produit.", example=4.0)
    product_weight_g: float = Field(..., description="Poids du produit en grammes.", example=500.0)
    product_length_cm: float = Field(..., description="Longueur du produit en cm.", example=19.0)
    product_height_cm: float = Field(..., description="Hauteur du produit en cm.", example=8.0)
    product_width_cm: float = Field(..., description="Largeur du produit en cm.", example=13.0)

class AutoEncoderRequest(BaseModel):
    delivery_days: float = Field(..., description="Nombre de jours entre achat et livraison.", example=8.0)
    delay_days: float = Field(..., description="Nombre de jours de retard ou d avance.", example=-8.0)
    purchase_month: float = Field(..., description="Mois d achat.", example=10.0)
    purchase_dow: float = Field(..., description="Jour de la semaine d achat.", example=0.0)
    n_items: float = Field(..., description="Nombre d articles dans la commande.", example=1.0)
    total_price: float = Field(..., description="Prix total de la commande.", example=29.99)
    total_freight: float = Field(..., description="Frais de livraison totaux.", example=8.72)
    total_weight: float = Field(..., description="Poids total des articles.", example=500.0)
    payment_value: float = Field(..., description="Montant total paye.", example=38.71)
    max_installments: float = Field(..., description="Nombre maximal de mensualites.", example=1.0)
    review_score: float = Field(..., description="Note client sur 5.", example=4.0)
    bad_review: float = Field(..., description="Indicateur binaire avis negatif (0 ou 1).", example=0.0)

class SentimentInput(BaseModel):
    text: str = Field(..., description="Texte de l avis client a analyser.", example="Produit excellent, livraison rapide et client tres satisfait")


class RecommendationInput(BaseModel):
    product_id: str = Field(..., description="Identifiant du produit pour lequel on veut des recommandations.", example="87285b34884572647811a353c7ac498a")