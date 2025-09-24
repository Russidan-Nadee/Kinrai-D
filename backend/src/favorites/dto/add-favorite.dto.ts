import { IsInt } from 'class-validator';

export class AddFavoriteDto {
  @IsInt()
  menu_id: number;
}
